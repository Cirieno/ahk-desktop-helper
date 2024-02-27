# AHK Desktop Helper

### What is it?

A collection of small enhancements for Windows.

Written in AutoHotkey v2, the script can either be run as-is or compiled into an executable using AHK2Exe w/ MPRESS from the Autohotkey site.

On first run AHKDH will make a `user_settings.ini` file with some default vales - edit the key values to turn options and modules on or off.

`Enabled` means show the module in the app menu at all.

`On` means the module or item(s) will be active on load.

These are things I wrote for myself and use on a daily(ish) basis.  Only tested on Win10 so far.

### `Environment`

##### `startWithWindows`

Creates a shortcut in the user's Start Menu startup folder

##### `enableTextManipulationHotkeys`

Enables some global hotkeys that can change any selected text:

`Ctrl + Alt + u` = uppercase

`Ctrl + Alt + l` = lowercase

`Ctrl + Alt + t` = title case

`Ctrl + Alt + '` = enclose in single quotes

`Ctrl + Alt + 2` = enclose in double quotes

`Ctrl + Alt + 9` or `Ctrl + Alt + 0` = enclose in parentheses

`Ctrl + Alt + [` or `Ctrl + Alt + ]` = enclose in square brackets

`Ctrl + Alt + Shift + [` or `Ctrl + Alt + Shift + ]` = enclose in curly brackets



##### `enableExtendedRightMouseClick`

Transforms every right-click in Explorer windows into a Shift + Click, which reveals extra options in Explorer's right-click context menu.

### `AutoCorrect`

on|off = `[default, user]`

There are two autocorrect dictionaries - the default one with ~10k entries, and a user one for your own replacements.

Rename `user_autocorrect.template.txt` template to `user_autocorrect.txt`

A correction string is added in the format `<replacement>|<trigger>|modifiers`.  Most common modifiers are `?`, `*`, and `C`.

Correction strings can be straight replacements, or you can dynamically replace characters with the following optionals:
   `[abc]` = one of these characters must be present at this position
   `[abc]?` = one (or none) of these characters must be present at this position
   `[abc]+` = all of these characters must be present in any order

On first run a `user_autocorrect.txt` file will be created for you to add your own replacements.  I keep tinkering with and adding to `default_autocorrect.txt` so it's not a good idea to make changes to that file, though there might be strings that you want to comment out for your own environment.

### `KeyboardExplorerDialogSlashes`

Converts forward-slashes in a path into back-slashes.  Handy if you're working with any Unix-y environments on your Windows machine.

### `DesktopHideMediaPopup`

Hide the OSD volume popup

### `DesktopHidePeekButton`

Hide the small Desktop Peek button found at the end of the taskbar.

### `KeyboardKeylocks`

on|off = `[num, caps, scroll]`

Turn on or off the Caps Lock, Num Lock, Scroll Lock keys on load.

### `MouseSwapButtons`

Swap left and right mouse buttons.  Handy for left-handed people, or those like me with intermittent RSI.

### `VolumeMouseWheel`

step = `3`

Use the mousewheel to change volume anywhere over the system icons and date/time part of the taskbar.

### `VolumeSteps`

steps = `[10, 20, 25, 30, 33, 40, 50, 60, 66, 70, 75, 80, 90, 100]`

For those like me who are slightly OCD about their volume.
