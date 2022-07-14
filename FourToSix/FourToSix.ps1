#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Tiles between four and six Eye of Gnome Windows Across two monitors when used in Nautilus
.DESCRIPTION
    1.  Nautilus paths are retrieved from environment
    2.  Total Screen width across all monitors is retrieved with wmctrl
    3.  Active monitor quantity, dimensions, and offsets are retrieved with xrandr
    4.  Calculate number of windows to be displayed on each monitor as well as their widths
    5.  Calculate positioning and adjust widths in a way that takes into account an offset for eye of gnome
    6.  Get a list of currently open Eye of Gnome Windows so that they aren't manipulated
    7.  Launch EOG with a bash command that spawns a process that will function independent of the powershell session
    8.  Get the hexadecimal window ID associated with the new EOG process and associate it with the powershell object
    9.  Move and resize the widths of each Window using xdotool
    10. Add the vertical maximized property to each Window using wmctrl
.NOTES
    Script needs to be saved to $(HOME)/.local/share/nautilus/scripts folder
    Script needs to be made executable and nautilus needs to navigate to the scripts folder before it will show in the context menu
    Select between four and six image files in Nautilus: right click>scripts>Fourtosix.ps1 to use
    Requires xdotool and wmctrl
    Scripted with the following conditions in mind:
        1. Eye of Gnome is using X, not wayland
        2. Two 1080p monitors
        3. Monitors have horizontal span orientation
        4. Four, Five, or Six images are selected at a time
#>

function Get-NautilusPath
{
    $nautilusPaths=[System.Environment]::GetEnvironmentVariable("NAUTILUS_SCRIPT_SELECTED_FILE_PATHS")

    $nautilusPaths=$nautilusPaths.Split("`n",[System.StringSplitOptions]::RemoveEmptyEntries)

    return $nautilusPaths
}

function Get-DesktopWidth
{
    #regex extracts width of active (*) Desktop
    [int]$width=wmctrl -d | grep -oP '\*\s+DG:\s+\K([[:digit:]]+)'
    return $width
}

class Monitor
{
    [int]$Width
    [int]$Height
    [int]$XOffset
    [int]$YOffset
    [int]$Numerator
    [int]$NumCounter
}

function Get-Monitor
{
    [CmdletBinding()]
    [OutputType([Monitor[]])]
    #regex matches digitsxdigits+digits+digits format
    $strings=xrandr | grep -E -o '[[:digit:]]+x[[:digit:]]+\+[[:digit:]]+\+[[:digit:]]+'

    [Monitor[]]$out=@()

    for ($i=0; $i -lt $strings.Count; $i++)
    {
        $vals=$strings[$i].Split([char[]]@('+','x'))
        $out+=[Monitor]@{
            Width=$vals[0]
            Height=$vals[1]
            Xoffset=$vals[2]
            YOffset=$vals[3]
            Numerator=0
            NumCounter=0
        }
    }

    $out=$out | Sort-Object -Property Xoffset

    return $out
}

function Get-Numerator
{
    <#
    .SYNOPSIS
        Numerator in the sense that it's the number of windows per monitor of total windows
        Used as denominator in deciding per window width
    #>
    
    [OutputType([Monitor[]])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $DesktopWidth,
        [Parameter()]
        [Monitor[]]
        $Monitors,
        [Parameter()]
        [int]
        $Count
    )

    [float]$Reference=$DesktopWidth/$Count

    [int]$Remaining=$Count

    for ($i=0; $i -lt $Monitors.Count; $i++)
    {
        $Width=$Monitors[$i].Width
        #Assign remainder
        if (($Width/$Remaining) -gt $Reference)
        {
            $Monitors[$i].Numerator=$Remaining
        #Round the numerator
        }elseif (($Width%$Reference) -ne 0)
        {
            $Numerator=[math]::round(($Width/$Reference),[System.MidpointRounding]::AwayFromZero)
            $Remaining-=$Numerator
            $Monitors[$i].Numerator=$Numerator
        }else{
            $Numerator=$Width/$Reference
            $Monitors[$i].Numerator=$Numerator
            $Remaining-=$Numerator
        }
    }

    return $Monitors

}

class Window
{
    [string]$Id
    [int]$Width
    [int]$XOffset
    [string]$Path
}

function Get-Window
{
    [OutputType([Window[]])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [Monitor[]]
        $Monitors,
        [Parameter()]
        [string[]]
        $Paths
    )

    #Eog has 26 pixel shadow to left and right of window in testing
    #Shadow effects size of both sides but only lefthand placement of the very first window
    $Shadow=26

    [Window[]]$Windows=@()

    $MonitorIndex=0

    for ($i=0; $i -lt $Paths.Count; $i++)
    {
        if ($Monitors[$MonitorIndex].NumCounter -eq 0)
        {
            [int]$Width=($Monitors[$MonitorIndex].Width)/($Monitors[$MonitorIndex].Numerator)

            $Windows+=[Window]@{
                Width=$Width+(2*$Shadow)
                XOffset=$Monitors[$MonitorIndex].XOffset-$Shadow
                Path=$Paths[$i]
            }

            $Monitors[$MonitorIndex].NumCounter+=1
        } else
        {
            [int]$Width=($Monitors[$MonitorIndex].Width)/($Monitors[$MonitorIndex].Numerator)
            $XOffset=$Windows[-1].XOffset+$Width

            $Windows+=[Window]@{
                Width=$Width+(2*$Shadow)
                XOffset=$XOffset
                Path=$Paths[$i]
            }

            $Monitors[$MonitorIndex].NumCounter+=1
        }

        if ($Monitors[$MonitorIndex].NumCounter -eq $Monitors[$MonitorIndex].Numerator)
        {
            $MonitorIndex+=1
        }
    }

    return $Windows
}

class wmctrl
{
    [string]$Id
    [int]$Desktop
    [string]$Client
    [string]$Title
}

function ConvertTo-WMCtrl
{
    [OutputType([wmctrl[]])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $wmctrl
    )

    Process{
        $split=$wmctrl.Split("`n",[System.StringSplitOptions]::RemoveEmptyEntries)

        [wmctrl[]]$wmctrlArray=@()

        for ($i=0; $i -lt $split.Count; $i++)
        {
            $wmctrlSplit=$split[$i].Split(" ",4,[System.StringSplitOptions]::RemoveEmptyEntries)
            $wmctrlArray+=@{
                Id=$wmctrlSplit[0]
                Desktop=$wmctrlSplit[1]
                Client=$wmctrlSplit[2]
                Title=$wmctrlSplit[3]
            }
        }
        return $wmctrlArray
    }
    
}

function Get-EOGExclusion
{
    [OutputType([string[]])]
    [CmdletBinding()]
    param (
    )

    [string[]]$ExclusionList=@()

    $ExclusionList+=(wmctrl -l | ConvertTo-WMCtrl | Where-Object {$_.Title -eq "Image Viewer"}).Id

    return $ExclusionList
}

function Start-EOG
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Image
    )
    bash -c "nohup eog '$Image' >/dev/null 2>&1 &"
}

class IdHolder
{
    [string[]]$ExclusionList
    [string]$Id
}

function Get-EOGHolder
{
    [OutputType([IdHolder])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [IdHolder]
        $Holder
    )

    $Holder.Id=""

    [bool]$Opened=$false

    do
    {
        Start-Sleep -Milliseconds 200
        $Holder.Id=(wmctrl -l | ConvertTo-WMCtrl | Where-Object {($_.Title -eq "Image Viewer") -and ($Holder.ExclusionList -notcontains $_.Id)}).Id
        $Opened=([string]::IsNullOrWhiteSpace($Holder.Id) -eq $false)
    } while ($Opened -ne $true)

    $Holder.ExclusionList+=$Holder.Id

    return $Holder
}

class WindowHolder
{
    [IdHolder]$Holder
    [Window[]]$Windows
}

function Get-WindowID
{
    [OutputType([WindowHolder])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [WindowHolder]
        $WindowHolder
    )

    for ($i=0; $i -lt $WindowHolder.Windows.Count; $i++)
    {
        $C=$WindowHolder.Windows[$i]
        Start-EOG -Image $C.Path | Out-Null
        $WindowHolder.Holder=Get-EOGHolder $WindowHolder.Holder
        $WindowHolder.Windows[$i].Id=$WindowHolder.Holder.Id
    }

    return $WindowHolder
}

function Move-EOG
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [Window[]]
        $Windows
    )

    for ($i=0; $i -lt $Windows.Count; $i++)
    {
        $C=$Windows[$i]
        #Move and horizontally resize window
        xdotool windowsize $C.Id $C.Width y windowmove $C.Id $C.XOffset y
        #vertically maximize window
        wmctrl -i -r $C.Id -b add,maximized_vert
    }
}

#Script Start

[string[]]$Paths=Get-NautilusPath

$DesktopWidth=Get-DesktopWidth
$Monitors=Get-Monitor
$Monitors=Get-Numerator $DesktopWidth $Monitors $Paths.Count
$Windows=Get-Window $Monitors $Paths

#Prevent script from manipulating already open EOG Windows
$ExclusionList=Get-EOGExclusion

$Holder=[IdHolder]@{                                                                                                            
    Id=""
    ExclusionList=$ExclusionList
}

$WindowHolder=[WindowHolder]@{
    Holder=$Holder
    Windows=$Windows
}

$WindowHolder=Get-WindowID $WindowHolder

Move-EOG $WindowHolder.Windows
