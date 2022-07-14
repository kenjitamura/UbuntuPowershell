### SYNOPSIS  

Tiles between four and six Eye of Gnome windows across two monitors when used in Nautilus

### DESCRIPTION  

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

### NOTES  

Script needs to be saved to $(HOME)/.local/share/nautilus/scripts folder
Script needs to be made executable and nautilus needs to navigate to the scripts folder before it will show in the context menu
Select between four and six image files in Nautilus: right click>scripts>Fourtosix.ps1 to use
Requires xdotool and wmctrl
Scripted with the following conditions in mind:
1. Eye of Gnome is using X, not wayland
2. Two 1080p monitors
3. Monitors have horizontal span orientation
4. Four, Five, or Six images are selected at a time

### PREVIEW  

![Script](./Demonstration0.png?raw=true "Script Selection")
![Left Monitor](./Demonstration1.png?raw=true "Left Monitor")
![Right Monitor](./Demonstration2.png?raw=true "Right Monitor")
