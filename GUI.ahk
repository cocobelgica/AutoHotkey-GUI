main := new GUI({options:"+Resize", color:"White", font:"s9,Consolas"})
btnA := main.add("Button", {options:"w120 h30", text:"Hello World"})
btnA.handler := "Fn"
btnB := main.add("Button", {options:"xp y+10 wp hp"})
btnB.text := "Another Button" , btnB.handler := "Fn"
lbl := main.add("Text", {options:"xp y+10 w200"})
lbl.font := "cRed s10 italic bold,Arial"
lbl.text := "Hello World" , lbl.handler := "Fn"
main.show("w200 h300")
return

Fn(oCtrl) {
	MsgBox, % oCtrl.handle "`n" oCtrl.__var "`n" oCtrl.classNN "`n" oCtrl.text
}

class GUI
{

	static __ := GUI.__INIT__()

	class __PROPERTIES__
	{

		__Call(target, name, params*) {
			if !(name ~= "i)^(base|__Class)$") {
				return ObjHasKey(this, name)
				       ? this[name].(target, params*)
				       : this.__.(target, name, params*)
			}
		}
	}
	
	__New(arg) {
		this.Insert("_", {__ctrls:new GUI.__GUICONTROL__(this)})

		Gui, New, % "HwndhGui Label__GUI_"
		GUI.__[this.handle:=hGui] := &this

		for k, v in arg
			this[k] := v

		;Gui, % this.handle ":Show", Hide AutoSize
	}

	__Delete() {
		if this.handle
			this.destroy()
		OutputDebug, DELETED
	}

	__Set(k, v, p*) {

		hGui := this.handle
		if (!hGui && k <> "handle")
			throw Exception("ERROR", -1)

		if (k = "handle") {

		}

		if (k = "options") {
			Gui, % hGui ":" v
			Loop, Parse, v, % " `t"
			{
				if !RegExMatch(A_LoopField, "Oi)^(\+|-)(.*)$", m)
					continue
				this._[m.2] := {"+":1, "-":0}[m.1]
			}
		}

		if (k = "title") {
			dhw := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinSetTitle, % "ahk_id " this.handle,, % v
			DetectHiddenWindows, % dhw
		}

		if (k = "color") {
			Gui, % hGui ":Color", % v
		}

		if (k = "margin") {
			if !RegExMatch(v, "O)^(\d+)[,\s\t]+(\d+)$", m)
				throw Exception("ERROR", -1)
			Gui, % hGui ":Margin", % m.1, % m.2
		}

		if (k = "font") {
			if !RegExMatch(v, "O)^([^,]+),(.*)$", m)
				throw Exception("ERROR", -1)
			Gui, % hGui ":Font", % m.1, % m.2
		}

		return this._[k] := v
	}

	class __Get extends GUI.__PROPERTIES__
	{

		__(k, p*) {
			if this._.HasKey(k)
				return this._[k, p*]

			return false
		}

		title(p*) {
			dhw := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGetTitle, title, % "ahk_id " this.handle
			DetectHiddenWindows, % dhw
			return title
		}

		control(p*) {
			return p.MinIndex() ? this.__ctrls[p*] : this.__ctrls
		}
	
	}

	add(ctrl, arg) {
		if !CONTROL.HasKey(ctrl)
			throw Exception("ERROR", -1)
		ctrlClass := CONTROL[ctrl]
		return new ctrlClass(this, arg)
	}

	show(options:="") {
		Gui, % this.handle ":Show", % options
	}

	destroy() {
		this.control.__del()
		Gui, % this.handle ":Destroy"
		this.handle := false
	}

	class __GUICONTROL__
	{

		__New(oGui) {
			this.Insert("_", [])
			this.__GUI := &oGui
		}

		__Set(k, v, p*) {
			return this._[k] := v
		}

		class __Get extends GUI.__PROPERTIES__
		{

			__(k, p*) {
				if this.__has(k) {
					/*
					if DllCall("IsWindow", "Ptr", k) {
						GuiControlGet, name, % this.gui.handle ":Name", % k
						oCtrl := Object(SubStr(name, 3))
						return p.MinIndex() ? oCtrl[p*] : oCtrl
					}
					*/
					return this._[k, p*]
				}

				GuiControlGet, hCtrl, % this.gui.handle ":Hwnd", % k
				return hCtrl ? this[hCtrl, p*] : false
			}

			gui(p*) {
				return Object(this.__GUI)
			}

			list(p*) {
				dhw := A_DetectHiddenWindows
				DetectHiddenWindows, On
				list := []
				WinGet, ctrls, ControlListHwnd, % "ahk_id " this.gui.handle
				Loop, Parse, ctrls, `n
					list[A_Index] := this[A_LoopField]
				DetectHiddenWindows, % dhw
				return p.MinIndex()
				       ? (list.HasKey(p.1) ? list[p.1] : list)
				       : list
			}

			focus(p*) {
				GuiControlGet, focus, % this.gui.handle ":Focus"
				return (focus <> "") ? this[focus] : false
			}
		}

		__has(k) {
			return this._.HasKey(k)
		}

		__del(k:="") {
			prm := (k <> "") ? (k <> "__GUI" ? [k, ""] : [k]) : false
			return prm ? this._.Remove(prm*) : this._ := []
		}
	}

	class __CONTROL__
	{

		__New(oGui, arg) {
			static
			local hCtrl, pCtrl
			
			this.Insert("_", [])
			pCtrl := &this

			Gui, % oGui.handle ":Add"
			   , % this.__type
			   , % "HwndhCtrl g__GUI_Label v__" pCtrl " " arg.options
			   , % arg.text
			
			this.handle := hCtrl , this.__var := "__" pCtrl
			(oGui.__ctrls)[this.handle] := this
		}

		__Delete() {
			;OutputDebug, CONTROL DELETED
		}

		__Set(k, v, p*) {
			parent := this.parent

			if (k = "text") {
				GuiControl, % parent.handle ":", % this.handle, % v
			}

			if (k = "font") {
				if !RegExMatch(v, "O)^([^,]+),(.*)$", m)
					throw Exception("ERROR", -1)
				RegExMatch(parent.font, "O)^([^,]+),(.*)$", old)
				Gui, % parent.handle ":Font"
				Gui, % parent.handle ":Font", % m.1, % m.2
				GuiControl, % parent.handle ":Font", % this.handle
				Gui, % parent.handle ":Font"
				Gui, % parent.handle ":Font", % old.1, % old.2

			}

			if (k = "handler") {

			}

			return this._[k] := v
		}

		class __Get extends GUI.__PROPERTIES__
		{

			__(k, p*) {
				if this._.HasKey(k)
					return this._[k, p*]

				return false
			}

			parent(p*) {
				hParent := DllCall("GetParent", "Ptr", this.handle)
				return Object(GUI.__[hParent])
			}

			classNN(p*) {
				parent := this.parent
				dhw := A_DetectHiddenWindows
				DetectHiddenWindows, On
				WinGet, ctrls, ControlList, % "ahk_id " parent.handle
				Loop, Parse, ctrls, `n
					ControlGet, hCtrl, Hwnd,
					          , % (classNN:=A_LoopField)
					          , % "ahk_id " parent.handle 
				until (hCtrl == this.handle)
				DetectHiddenWindows, % dhw
				return classNN
			}

			text(p*) {
				GuiControlGet, text, % this.parent.handle ":", % this.handle
				return text
			}
		}

		onEvent() {
			static $

			$ := this.handle
			SetTimer, __CONTROL_Timer, -1
			return
			__CONTROL_Timer:
			($:=GUI.__GET__($)).handler.($)
			$ := ""
			return
		}
	}

	__INIT__() {
		static init

		if init
			return false
		GUI.base := GUI.__BASE__
		init := true
		return []
	}

	class __BASE__
	{

		class __Get extends GUI.__PROPERTIES__
		{

			__(k, p*) {
				if this._.HasKey(k)
					return this._[k, p*]

				return false
			}

			__this__(p*) {
				return Object(GUI.__[A_Gui])
			}

			__thisCtrl__(p*) {
				return Object(SubStr(A_GuiControl, 3))
			}
		}

		__GET__(hWnd) {
			if !DllCall("IsWindow", "Ptr", hWnd)
				throw Exception("ERROR", -1)
			dhw := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGetClass, class, % "ahk_id " hWnd
			if (class == "AutoHotkeyGUI")
				obj := GUI.__.HasKey(hWnd) ? Object(GUI.__[hWnd]) : false
			else {
				hParent := DllCall("GetParent", "Ptr", hWnd)
				GuiControlGet, name, % hParent ":Name", % hWnd
				obj := Object(SubStr(name, 3))
			}
			DetectHiddenWindows, % dhw
			return obj
		}
	
	}

	__HANDLER__() {
		return

		__GUI_Close:
		GUI.__this__.destroy()
		SetTimer, __GUI_Exit, -1
		return

		__GUI_Label:
		GUI.__thisCtrl__.onEvent()
		return

		__GUI_Exit:
		ExitApp
	}
}

class CONTROL
{	
	class Button extends GUI.__CONTROL__
	{
		static __type := "Button"
	}

	class CheckBox extends GUI.__CONTROL__
	{
		static __type := "CheckBox"
	}

	class ComboBox extends GUI.__CONTROL__
	{
		static __type := "ComboBox"
	}

	class DateTime extends GUI.__CONTROL__
	{
		static __type := "DateTime"
	}

	class DropDownList extends GUI.__CONTROL__
	{
		static __type := "DDL"
	}

	class Edit extends GUI.__CONTROL__
	{
		static __type := "Edit"
	}

	class GroupBox extends GUI.__CONTROL__
	{
		static __type := "GroupBox"
	}

	class Hotkey extends GUI.__CONTROL__
	{
		static __type := "Hotkey"
	}

	class ListBox extends GUI.__CONTROL__
	{
		static __type := "ListBox"
	}

	class ListView extends GUI.__CONTROL__
	{
		static __type := "ListView"
	}

	class MonthCal extends GUI.__CONTROL__
	{
		static __type := "MonthCal"
	}

	class Progress extends GUI.__CONTROL__
	{
		static __type := "Progress"
	}

	class Radio extends GUI.__CONTROL__
	{
		static __type := "Radio"
	}

	class Slider extends GUI.__CONTROL__
	{
		static __type := "Slider"
	}

	class StatusBar extends GUI.__CONTROL__
	{
		static __type := "StatusBar"
	}

	class Tab extends GUI.__CONTROL__
	{
		static __type := "Tab2"
	}

	class Text extends GUI.__CONTROL__
	{
		static __type := "Text"
	}

	class TreeView extends GUI.__CONTROL__
	{
		static __type := "TreeView"
	}

	class UpDown extends GUI.__CONTROL__
	{
		static __type := "UpDown"
	}
}