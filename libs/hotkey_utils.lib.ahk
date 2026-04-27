/**********************************************************
 * @type {AHKLibrary}
 * @name Hotkey Utils
 * @author Rob McInnes (Cirieno)
 * @file hotkey_utils.lib.ahk
 *********************************************************/


class HotkeyUtils {
	/**
	 * @param {string} hotkeyName
	 * @returns {string}
	 */
	static normaliseHotkey(hotkeyName) {
		return (isString(hotkeyName) ? Trim(hotkeyName) : "")
	}


	/**
	 * @param {string} hotkeyName
	 * @param {string} fallbackHotkey
	 * @param {Func|BoundFunc} callback
	 * @returns {string}
	 */
	static validateHotkey(hotkeyName, fallbackHotkey, callback) {
		hotkeyName := HotkeyUtils.normaliseHotkey(hotkeyName)
		fallbackHotkey := HotkeyUtils.normaliseHotkey(fallbackHotkey)

		if (isEmpty(hotkeyName)) {
			return fallbackHotkey
		}

		try {
			Hotkey(hotkeyName, callback, "off")
			return hotkeyName
		} catch Error {
			return fallbackHotkey
		}
	}


	/**
	 * @param {string} hotkeyName
	 * @returns {string}
	 */
	static formatHotkeyForDisplay(hotkeyName) {
		parts := []
		display := StrReplace(hotkeyName, "$", "")

		if (InStr(display, "^")) {
			parts.Push("Ctrl")
			display := StrReplace(display, "^", "")
		}

		if (InStr(display, "!")) {
			parts.Push("Alt")
			display := StrReplace(display, "!", "")
		}

		if (InStr(display, "+")) {
			parts.Push("Shift")
			display := StrReplace(display, "+", "")
		}

		if (InStr(display, "#")) {
			parts.Push("Win")
			display := StrReplace(display, "#", "")
		}

		if (!isEmpty(display)) {
			parts.Push(display)
		}

		return parts.Join("+")
	}
}
