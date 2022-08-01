class search {
    [string]$apprenticeshipOnlyFlag
    [string]$autoSearchFlag
    [string]$availability
    [string]$counties
    [string]$daysOff
    [string]$emprName
    [string]$fcjlflag
    [string]$filter
    [string]$hideJobsViewed
    [string]$includeOjtFlag
    [string]$internshipOnlyFlag
    [string]$jadrIds
    [string]$jobOrderDays
    [string]$keywords
    [string]$keywordsAndOr
    [string]$keywordsLoc
    [string]$keywordsNoLoc
    [string]$lastSearchFlag
    [string]$latitude
    [string]$locationType
    [string]$longitude
    [string]$minimumAge
    [string]$offices
    [string]$onetClasses
    [string]$onets
    [string]$onetType
    [string]$radius
    [string]$regions
    [string]$searchName
    [string]$searchType
    [string]$shift
    [string]$socCode
    [string]$sortOrder
    [string]$telecommuteFlag
    [string]$tempAgencyFlag
    [string]$wage
    [string]$wageTypeCode
    [string]$zip

    search(
        [string]$keywords,
        [int]$zip,
        [int]$radius,
        [string]$tempAgencyFlag
    ) {
        $this.keywords = $keywords
        $this.filter = ""
        $this.keywordsAndOr = "O"
        $this.radius = $radius.ToString()
        $this.tempAgencyFlag = $tempAgencyFlag
        $this.zip = $zip.ToString()
    }
}

class jobSearchPayload {
    [string]$cliId
    [string]$jadrId
    [string]$jobs
    [bool]$logged
    [array]$objectives
    [int]$page
    [int]$resultCount
    [search]$search
    [string]$searchId

    jobSearchPayload(
        [string]$keywords,
        [int]$zip,
        [int]$radius,
        [string]$tempAgencyFlag
    ) {
        $this.objectives = @()
        $this.page = 1
        $this.resultCount = 0
        $this.logged = $true
        $this.search = [search]::New($keywords, $zip, $radius, $tempAgencyFlag)
    }
}

class pair {
    [string]$name
    [string]$value

    pair(
        [string]$name,
        [string]$value
    ) {
        $this.name = $name
        $this.value = $value
    }
}

class callback {
    [string]$type
    [pair[]]$output
    [pair[]]$input
    [int]$_id

    callback(
        [string]$type,
        [pair[]]$output,
        [pair[]]$inputPair,
        [int]$_id
    ) {
        $this.type = $type
        $this.output = $output
        $this.input = $inputPair
        $this._id = $_id
    }
}

class passwordInput {
    [string]$authId
    [callback[]]$callbacks
    [string]$id
    [string]$header

    passwordInput(
        [string]$authId,
        [pscredential]$cred
    ) {
        $this.authId = $authId
        $this.id = "UserPassInput"
        $this.callbacks += [callback]::New(
            "HiddenValueCallback",
            [pair[]]@(
                [pair]::New("value", "UserPassInput"),
                [pair]::New("id", "stageIdentifier")
            ),
            [pair[]]@(
                [pair]::New("IDToken1", "stageIdentifier")
            ),
            0
        )
        $this.callbacks += [callback]::New(
            "NameCallback",
            [pair[]]@(
                [pair]::New("prompt", "Username or Email")
            ),
            [pair[]]@(
                [pair]::New("IDToken2", $cred.UserName)
            ),
            1
        )
        $this.callbacks += [callback]::New(
            "PasswordCallback",
            [pair[]]@(
                [pair]::New("prompt", "Password")
            ),
            [pair[]]@(
                [pair]::New("IDToken3", $cred.GetNetworkCredential().Password)
            ),
            2
        )
    }
}

class job {
    [string]$Link
    [string]$City
    [string]$OpenDate
    [string]$Employer
    [string]$Industry
    [int]$Distance
    [string]$CloseDate
    [string]$Remote
}

function Convert-JobsToMarkDown {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int]
        $Age,
        [Parameter(ValueFromPipeline)]
        [object]
        $rawJob
    )

    Process {

        if ($Age -gt 0)
        {
            if ([datetime]$rawJob.openDate -lt [datetime]::Today.AddDays(-1*$Age))
            {
                return
            }
        }

        $jobTitle = ""
        $job = [job]@{}
        [string[]]$jobFields = @()
        $jobFields += ($rawJob | get-member | Where-Object { $_.Membertype -eq "NoteProperty" }).Name

        for ($i = 0; $i -lt $jobFields.Count; $i++) {
            $current = $jobFields[$i]

            if ($null -eq $rawJob.$current) {
                continue
            }

            switch ($current) {
                "url" { $job.Link = "<a href=`"$($rawJob.$current)`">Job Link</a>" }
                "jobTitle" { $jobTitle = $rawJob.$current }
                "city" { $job.City = $rawJob.$current }
                "openDate" { $job.OpenDate = $rawJob.$current }
                "employerName" { $job.Employer = $rawJob.$current }
                "industryName" { $job.Industry = $rawJob.$current }
                "miles" { $job.Distance = $rawJob.$current }
                "closeDate" { $job.CloseDate = $rawJob.$current }
                "telecommuteFlag" { $job.Remote = $rawJob.$current }
            }
        }

        $HTML = $job | ConvertTo-Html -Fragment -As List

        $HTML = [System.Web.HttpUtility]::HtmlDecode($HTML)

        $Row = @"
<tr><td>
<details>
<summary style=`"font-size:16px`">$($jobTitle)</summary>

$($HTML)
</details>
<tr><td>
"@
        
        return $Row
    }
}

#script start

#get User Input
[string]$keywords = Read-Host "Enter keyword search"
[int]$zip = Read-Host "Enter zip"
[int]$radius = Read-Host "Enter radius"
[int]$Age = Read-Host "Enter Cut Off Age in Days for Listing"

do {
    if ((get-error).FullyQualifiedErrorId -eq "ValidateSetFailure") { $Error.Clear() }
    [ValidateSet('Yes', 'No', 'Y', 'N')][string]$TempJobs = Read-Host "Include Temp Jobs? Y/N"
} while ((get-error).FullyQualifiedErrorId -eq "ValidateSetFailure")

$TempJobs = switch ($TempJobs) {
    "Yes" { "N" }
    "Y" { "N" }
    "No" { "Y" }
    "N" { "Y" }
}

$cred = Get-Credential

#Create Job search Json Payload
$jobPayload = [jobSearchPayload]::New($keywords, $zip, $radius, $TempJobs) | convertTo-Json -Compress -Depth 100

#Start session
Invoke-RestMethod -Method Get -Uri 'https://jobs.utah.gov/' -WebSession $MySession -SessionVariable 'MySession' | Out-Null

#Get asp.net session id
Invoke-RestMethod -Method Get -Uri 'https://jobs.utah.gov/sso/header.aspx' -WebSession $MySession | Out-Null

#Get client id Uri
Invoke-RestMethod -Method Get -Uri 'https://jobs.utah.gov/sso/login.aspx?application=UWORKSSKR' -WebSession $MySession | Out-Null

#get auth id
$authId = (Invoke-RestMethod -Method Post -Uri 'https://login.dts.utah.gov/sso/json/realms/root/authenticate' -WebSession $MySession).authId

#Authenticate
Invoke-RestMethod -Method Post -Uri 'https://login.dts.utah.gov/sso/json/realms/root/authenticate' -WebSession $MySession -ContentType 'application/json' `
    -Body $([passwordInput]::New($authId, $cred) | ConvertTo-Json -Compress -Depth 100) | Out-Null

#Authorize
Invoke-RestMethod -Method Get -Uri 'https://login.dts.utah.gov/sso/oauth2/authorize' -WebSession $MySession | Out-Null

#Search query
$RawResults = Invoke-RestMethod -ContentType "application/json" -Method Put -Body $jobPayload -Uri "https://jobs.utah.gov/jsp/utjobs//rest/seeker/home/search/new-job-search.json?rowsToFetch=300" -WebSession $MySession

[string]$MarkDown ="<table>"

$MarkDown += $RawResults.jobs | Sort-Object -Property openDate -Descending | Convert-JobsToMarkDown $Age

$MarkDown += "</table>"

Set-Content ./test.md -Value $MarkDown