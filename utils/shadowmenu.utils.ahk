; UTILS: ShadowMenu
; =====================================
; A set of functions that allow me to keep track of menus and the state of their items
; Some modules want to share menus that may not already exist
; Also, there's no exposed way to get the state of a menu item in AHKv2, only to set states
; It's not imperative to use this system, but it's a good way to keep track of menus and their items
; TODO: turn this into an object with methods and recursive-ivity



/**
 * @param {(menu|number|string)} [menuRef:=null] menu object | handle | path
 * @returns {(menu|null)} menu object | null
 */
getMenu(menuRef?) {
	menuRef := (IsSet(menuRef) && isMenuRef(menuRef) ? menuRef : null)

	thisMenu := (isMenu(menuRef) ? menuRef : null)

	if (!isMenu(thisMenu) && IsNumber(menuRef) && (menuRef > 0)) {
		thisMenu := MenuFromHandle(menuRef)
	}

	if (!isMenu(thisMenu) && isString(menuRef) && _ShadowMenu.menus.has(menuRef)) {
		thisMenu := MenuFromHandle(_ShadowMenu.menus[menuRef].handle)
	}

	return (isMenu(thisMenu) ? thisMenu : null)
}



/**
 * @param {string} [menuPath:=null]
 * @param {(menu|number|string)} [parentMenuRef:=null] menu object | handle | path
 * @returns {menu} menu object
 */
setMenu(menuPath?, parentMenuRef?) {
	menuPath := (IsSet(menuPath) && isString(menuPath) ? menuPath : null)
	parentMenuRef := (IsSet(parentMenuRef) && isMenuRef(parentMenuRef) ? parentMenuRef : null)

	parentMenu := (isMenu(parentMenuRef) ? parentMenuRef : getMenu(parentMenuRef))
	if (!isMenu(parentMenu)) {
		throw Error("ParentMenu not found")
	}

	thisMenu := Menu()

	menuVals := {
		type: "menu",
		path: menuPath,
		handle: thisMenu.handle,
		parentHandle: parentMenu.handle,
		items: []
	}
	_ShadowMenu.menus.set(menuVals.path, menuVals)
	thisMenu.vals := _ShadowMenu.menus[menuVals.path]

	return thisMenu
}



/**
 * @param {string} [labelRef:=null] menuItem label or path or id or position
 * @param {(menu|number|string)} [menuRef:=null] menu object | handle | path
 * @returns {(ref|null)} pointer to menuItem in _ShadowMenu | null
 */
getMenuItem(labelRef?, menuRef?) {
	labelRef := (IsSet(labelRef) && (isString(labelRef) || IsNumber(labelRef)) ? labelRef : null)
	menuRef := (IsSet(menuRef) && isMenuRef(menuRef) ? menuRef : null)

	if (_ShadowMenu.items.has(labelRef)) {
		return _ShadowMenu.items[labelRef]
	}

	thisMenu := (isMenu(menuRef) ? menuRef : getMenu(menuRef))
	if (!isMenu(thisMenu)) {
		throw Error("Menu not found")
	}

	if (isMenu(thisMenu) && thisMenu.HasOwnProp("vals") && thisMenu.vals.HasOwnProp("items") && isArray(thisMenu.vals.items)) {
		loop thisMenu.vals.items.length {

			if (isString(labelRef) && !isNull(labelRef) && (thisMenu.vals.items[A_Index].label == labelRef)) {
				return _ShadowMenu.items[thisMenu.vals.items[A_Index].path]
			}

			if (IsNumber(labelRef) && !isNull(labelRef) && (thisMenu.vals.items[A_Index].id == labelRef)) {
				return _ShadowMenu.items[thisMenu.vals.items[A_Index].path]
			}
		}

		if (IsNumber(labelRef) && (labelRef > 0) && (labelRef <= thisMenu.vals.items.length)) {
			return thisMenu.vals.items[labelRef]
		}
	}

	return null
}



/**
 * @param {string} [label:=null] menuItem label
 * @param {(menu|number|string)} [menuRef:=null] menu object | handle | path
 * @param {(object|string)} [CallbackOrSubmenu:=null]
 * @param {object} [props:=null]
 * @returns {ref} pointer to menuItem in _ShadowMenu
 */
setMenuItem(label?, menuRef?, CallbackOrSubmenu?, props?) {
	label := (IsSet(label) && isString(label) ? label : null)
	menuRef := (IsSet(menuRef) && isMenuRef(menuRef) ? menuRef : null)
	CallbackOrSubmenu := (IsSet(CallbackOrSubmenu) ? CallbackOrSubmenu : null)
	props := (IsSet(props) && IsObject(props) ? props : {})

	thisMenu := (isMenu(menuRef) ? menuRef : getMenu(menuRef))
	if (!isMenu(thisMenu)) {
		throw Error("Menu not found")
	}

	thisMenuVals := getMenuVals()
	getMenuVals() {
		for key, vals in _ShadowMenu.menus {
			if ((vals.type == "menu") && (vals.handle == thisMenu.handle)) {
				return vals
			}
		}
		return {}
	}

	if (isFunction(CallbackOrSubmenu) || isMenu(CallbackOrSubmenu)) {
		thisMenu.add(label, CallbackOrSubmenu)
	} else if ((label == "---") || (strLower(label) == "separator")) {
		thisMenu.add()
	} else {
		throw Error("CallbackOrSubmenu not a function or menu")
	}

	itemCount := DllCall("GetMenuItemCount", "ptr", thisMenu.handle)
	menuItemId := DllCall("GetMenuItemID", "ptr", thisMenu.handle, "int", (itemCount - 1))
	menuItemPostion := itemCount

	menuItemPath := (thisMenuVals.HasOwnProp("path") ? thisMenuVals.path : "TRAY") . "\" . label

	menuItemVals := {
		type: "item",
		label: label,
		path: menuItemPath,
		enabled: true,
		checked: false,
		iconPath: null,
		id: menuItemId,
		clickCount: 0,
		position: menuItemPostion,
		parentHandle: thisMenu.handle
	}
	_ShadowMenu.items.set(menuItemVals.path, menuItemVals)
	thisMenu.vals.items.push(_ShadowMenu.items[menuItemVals.path])

	return _ShadowMenu.items[menuItemVals.path]
}



/**
 * @param {string} [labelRef:=null] menuItem label or path
 * @param {(menu|number|string)} [menuRef:=null] menu object | handle | path
 * @param {object} [props:=null]
 * @returns {ref} pointer to menuItem in _ShadowMenu
 */
setMenuItemProps(labelRef?, menuRef?, props?) {
	labelRef := (IsSet(labelRef) && isString(labelRef) ? labelRef : null)
	menuRef := (IsSet(menuRef) && isMenuRef(menuRef) ? menuRef : null)
	props := (IsSet(props) && IsObject(props) ? props : null)

	thisMenu := (isMenu(menuRef) ? menuRef : getMenu(menuRef))
	if (!isMenu(thisMenu)) {
		throw Error("Menu not found")
	}

	thisMenuItem := getMenuItem(labelRef, menuRef)
	if (!IsObject(thisMenuItem)) {
		throw Error("MenuItem not found")
	}

	if (IsObject(props)) {
		if (props.HasOwnProp("enabled")) {
			(isTruthy(props.enabled) ? thisMenu.enable(thisMenuItem.label) : thisMenu.disable(thisMenuItem.label))
			thisMenuItem.enabled := toBoolean(props.enabled)
		}
		if (props.HasOwnProp("checked")) {
			(isTruthy(props.checked) ? thisMenu.check(thisMenuItem.label) : thisMenu.uncheck(thisMenuItem.label))
			thisMenuItem.checked := toBoolean(props.checked)
		}
		if (props.HasOwnProp("label")) {
			thisMenu.rename(thisMenuItem.label, props.label)
			thisMenuItem.label := props.label
		}
		if (props.hasOwnProp("clickCount")) {
			thisMenuItem.clickCount++
		}
		; if (props.HasOwnProp("iconPath")) {
		; 	thisMenu.modify(thisMenuItem.label, "Icon", props.iconPath)
		; 	thisMenuItem.iconPath := props.iconPath
		; }
	}

	return _ShadowMenu.items[thisMenuItem.path]
}



/**
 * @param {string} [labelRef:=null] menuItem label or path
 * @param {(menu|number|string)} [menuRef:=null] menu object | handle | path
 * @param {string} [prop:=null]
 * @returns {(boolean|number|string|null)}
 */
getMenuItemProp(labelRef?, menuRef?, prop?) {
	labelRef := (IsSet(labelRef) && isString(labelRef) ? labelRef : null)
	menuRef := (IsSet(menuRef) && isMenuRef(menuRef) ? menuRef : null)
	prop := (IsSet(prop) && isString(prop) ? prop : null)

	thisMenu := (isMenu(menuRef) ? menuRef : getMenu(menuRef))
	if (!isMenu(thisMenu)) {
		throw Error("Menu not found")
	}

	thisMenuItem := getMenuItem(labelRef, menuRef)
	if (!IsObject(thisMenuItem)) {
		throw Error("MenuItem not found")
	}

	switch (prop) {
		case "enabled":
			return thisMenuItem.HasOwnProp("enabled") ? thisMenuItem.enabled : null
		case "checked":
			return thisMenuItem.HasOwnProp("checked") ? thisMenuItem.checked : null
		case "label":
			return thisMenuItem.HasOwnProp("label") ? thisMenuItem.label : null
		case "iconPath":
			return thisMenuItem.HasOwnProp("iconPath") ? thisMenuItem.iconPath : null
	}

	return null
}



isMenuRef(val) {
	return (isMenu(val) || IsNumber(val) || isString(val))
}



/**
 * @note this is a debug function
 */
alertMenuPaths() {
	msg := ""

	for key, vals in _ShadowMenu.menus {
		if (vals.type == "menu") {
			msg .= "[" . key . "]`n"
			if (vals.HasOwnProp("items") && isArray(vals.items) && vals.items.length) {
				loop vals.items.length {
					menuItem := _ShadowMenu.items[vals.items[A_Index].path]
					msg .= "   " . menuItem.label
					props := []
					if (menuItem.HasOwnProp("checked") && menuItem.checked) {
						props.push("C")
					}
					if (menuItem.HasOwnProp("enabled") && !menuItem.enabled) {
						props.push("D")
					}
					if (props.length) {
						msg .= " [" . join(props, ", ") . "]"
					}
					msg .= "`n"
				}
			}
			msg .= "`n"
		}
	}

	msg := StrReplace(msg, "TRAY\", "")
	MsgBox(msg, (_Settings.app.name . " — " . "Menu Paths" . U_ellipsis), (0 + 64 + 4096))
}
