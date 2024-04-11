# AHK Desktop Helper

A collection of small enhancements for Windows.

Written in AutoHotkey v2, the script can either be run as-is or compiled into an executable using AHK2Exe w/ MPRESS from the Autohotkey site.

 These are things I wrote for myself and use on a daily(ish) basis.  Only tested on Win10 so far.

## Modules

Each enhancement is presented via its own module which can be enabled via `settings.ini`.  Some modules can be auto-actived when loading the app.  Click `Settings > Save current config` to save the current states which will be active on load in the future.

`enabled=true` Make the module available to the app.

`active=true` or `active=[x,y]` The module or module items will be automatically activated on load.

---

### Environment

`startWithWindows=false` Creates a shortcut in the user's startup folder

`enableExtendedRightMouseClick=false` Always send a Shift + right-click in Explorer-based windows, which reveals extra options in Explorer's right-click context menu.

---

### AutoCorrect

There are two autocorrect lists: the Default one with some 9k entries, and the User one for your own replacements.

A correction string is added in the format `replacement | trigger | modifiers`.  Most common modifiers are `?`, `*`, and `C`.

Correction strings can be straight replacements, or you can dynamically replace characters with the following optionals:

|     |     |
| --- | --- |
| [abc] | one of these characters must be present at this position |
| [abc]! | one (or none) of these characters must be present at this position |
| [abc]+ | all of these characters must be present in any order |
| [abc]? | this phrase is optional |


On first run `user.autocorrect.txt` will be created for you to add your own replacements.

I keep tinkering with `default.autocorrect.txt` so it's not a good idea to make changes to that file.

---

### CloseAppsWithCtrlW

A list of apps that you want to close with the Ctrl+W shortcut.

`apps=["notepad.exe","vlc.exe"]` Add your own app exes to this list

---

### DesktopGatherWindows

Bring all windows to the main monitor and resize them if possible.  Handy for when a window opens outside the monitor workspace.

`resizeOnMove=true` Resize the window if it's resizeable

---

### DesktopHideMediaPopup

Hide the OSD volume popup.  (NB: this also hides the brightness popup)

`allowExternalChange=true` Allow changes to this setting via other apps or the Control Panel

`resetOnExit=true` Reset to the state that was active when AHK-DH was loaded

---

### DesktopHidePeekButton

Hide the small Desktop Peek button found at the end of the taskbar.

`allowExternalChange=true` Allow changes to this setting via other apps or the Control Panel

`resetOnExit=true` Reset to the state that was active when AHK-DH was loaded

---

### KeyboardExplorerBackspace

Use the backspace key to drill upwards in File Explorer windows and dialogs.

---

### KeyboardExplorerDialogSlashes

Converts forward-slashes in a path into back-slashes.  Handy if you're working with any Unix-y environments on your Windows machine.

---

### KeyboardTextManipulation

Enables some global hotkeys that can change the selected text:

| Syntax | Description |
| ------ | ----------- |
| Ctrl + Alt + U | uppercase |
| Ctrl + Alt + L | lowercase |
| Ctrl + Alt + T | title case |
| Ctrl + Alt + S | sarcasm case |
| Ctrl + Alt + ' | enclose in single quotes |
| Ctrl + Alt + 2 | enclose in double quotes |
| Ctrl + Alt + ` | enclose in backticks |
| Ctrl + Alt + 9 | enclose in parentheses |
| Ctrl + Alt + [ | enclose in square brackets |
| Ctrl + Alt + Shift + { | enclose in curly braces |
| Ctrl + Alt + Shift + < | enclose in angled brackets |
| Ctrl + Alt + J | join lines |
| Ctrl + Alt + - | insert an m-dash |

---

#### MouseSwapButtons

Swap left and right mouse buttons.  Handy for left-handed people, or those like me with intermittent RSI.

`allowExternalChange=true` Allow changes to this setting via other apps or the Control Panel

`resetOnExit=true` Reset to the state that was active when AHK-DH was loaded

---

#### VolumeMouseWheel

Use the mousewheel to change volume anywhere over the system icons and date/time part of the taskbar.

`step=3` The increment by which the volume will change
