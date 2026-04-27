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
}
