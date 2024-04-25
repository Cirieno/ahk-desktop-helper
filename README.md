# AHK Desktop Helper

A collection of small enhancements for Windows.

Written in AutoHotkey v2, the script can either be run as-is or compiled into an executable using AHK2Exe w/ MPRESS from the Autohotkey site.

 These are things I wrote for myself and use on a daily(ish) basis. Only tested on Win10 so far.

## Modules

Each enhancement is presented via its own module which can be enabled via `settings.ini`. Some modules can be auto-actived when loading the app. Click `Settings > Save current config` to save the current states which will be active on load in the future.

Common module options:

`enabled=true` Make the module available to the app.

`active=true` or `active=[x,y]` The module or module items will be automatically activated on load.

`allowExternalChange=true` Allow changes to this setting via other apps or the Control Panel.

`resetOnExit=true` Reset to the state that was active when AHK-DH was loaded.

---

#### Environment

`startWithWindows=false` Creates a shortcut in the user's startup folder

`enableExtendedRightMouseClick=false` Always send a Shift + right-click in Explorer-based windows, which reveals extra options in Explorer's right-click context menu.

---

#### AutoCorrect

There are many AHK autocorrect scripts out there, but this one has a different approach. It allows you to add a single entry (or accented words) that can expand to multiple correction strings.

There are two autocorrect lists: the Default one with some 9k entries, and the User one for your own replacements.

A correction string is added in the format `replacement | trigger | modifiers`.

Correction strings can be straight replacements, or you can dynamically replace characters with the following optionals:

| Syntax | Description |
| ------ | ----------- |
| [abc]* | one of these characters can optionally be at this position |
| [abc]? | one of these characters must be at this position |
| [abc]+ | all of these characters must be present in any order |
| [abc]! | this combination is optional |

Examples:

`directly|driectly` -> a straightforward replacement

`dis[s]?obedi[ea]?nt` -> is automatically expanded into three replacement strings: `dissobedient`, `dissobediant`, `disobediant`

`débâcle` -> is internally turned into `d[eé]b[aâ]cle`, which automatically expands into the replacement strings `debacle`, `debâcle`, `débacle`

Any duplicated replacements are automatically ignored, as are any strings that are identical to the replacement string.

On first run `user.autocorrect.txt` will be created for you to add your own replacements.

NB: I keep tinkering with `default.autocorrect.txt` so don't make changes to this file unless you're happy to diff between revisions. It might be better to put any overrides in `user.autocorrect.txt`.

---

#### CloseAppsWithCtrlW

A list of apps that you want to close with the Ctrl+W shortcut.

`apps=["notepad.exe","vlc.exe"]` Add your own apps to this list. Path not required.

---

#### DesktopGatherWindows

Bring all windows to the main monitor and resize them if possible. Handy for when a window opens outside the monitor workspace.

`resizeOnMove=true` Resize the window if possible.

---

#### DesktopHideMediaPopup

Hide the OSD volume popup. NB: this also hides the brightness popup.

---

#### DesktopHidePeekButton

Hide the small Desktop Peek button found at the end of the taskbar.

---

#### KeyboardExplorerBackspace

Use the backspace key to drill upwards in File Explorer windows and dialogs.

---

#### KeyboardExplorerDialogSlashes

Converts forward-slashes and multiple backslashes to a single back-slash when entered into a File Explorer dialog. Handy if you're working with any Unix-y environments on your Windows machine. Doesn't currently capture paste via mouse.

---

#### KeyboardTextManipulation

Enables these global hotkeys to change selected text:

| Syntax | Description | Example |
| ------ | ----------- | --------|
| `Ctrl` + `Alt` + `U` | uppercase |
| `Ctrl` + `Alt` + `L` | lowercase |
| `Ctrl` + `Alt` + `T` | title case | This Is An Example |
| `Ctrl` + `Alt` + `K` | kebab case | this-is-an-example |
| `Ctrl` + `Alt` + `S` | snake case | this_is_an_example |
| `Ctrl` + `Alt` + `&` | sarcasm case | tHIS is aN ExampLE |
| `Ctrl` + `Alt` + `'` | enclose in single quotes | ' ' |
| `Ctrl` + `Alt` + `"` | enclose in double quotes | " " |
| `Ctrl` + `Alt` + `Shift` + `'` | enclose in single curly quotes | ‘ ’ |
| `Ctrl` + `Alt` + `Shift` + `"` | enclose in double curly quotes | “ ” |
| `Ctrl` + `Alt` + `` ` `` | enclose in backticks | `` |
| `Ctrl` + `Alt` + `(` or `)` | enclose in parentheses | ( ) |
| `Ctrl` + `Alt` + `[` or `]` | enclose in square brackets | [ ] |
| `Ctrl` + `Alt` + `{` or `}` | enclose in curly braces | { } |
| `Ctrl` + `Alt` + `<` or `>` | enclose in angled brackets | < > |
| `Ctrl` + `Alt` + `-` | insert an n-dash | – |
| `Ctrl` + `Alt` + `_` | insert an m-dash | — |
| `Ctrl` + `Alt` + `J` | join lines | |
<!-- | `Ctrl` + `Alt` + `C` | camel case | ThisIsAnExample -->

---

### MouseSwapButtons

Swap left and right mouse buttons. Handy for left-handed people, or those like me with intermittent RSI.


---

### VolumeMouseWheel

Use the mousewheel to change volume anywhere over the system icons and date/time part of the taskbar.

`step=3` The increment by which the volume will change.

---

## Refs

### Extensions

https://marketplace.visualstudio.com/items?itemName=thqby.vscode-autohotkey2-lsp

https://marketplace.visualstudio.com/items?itemName=zero-plusplus.vscode-autohotkey-debug

### Word lists sources

https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings

https://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/Grammar_and_miscellaneous

https://en.wikipedia.org/wiki/Commonly_misspelled_English_words

https://web.archive.org/web/20190310225422/https://en.wiktionary.org/wiki/Appendix:English_words_with_diacritics

https://github.com/cdelahousse/Autocorrect-AutoHotKey
