main := new GUI()
main.show("w300 h400")
return
]::main:=""

class GUI
{
	
	static __ := []

	class _properties_
	{

		__Call(target, name, params*) {
			if !(name ~= "i)^(base|__Class)$") {
				return ObjHasKey(this, name)
				       ? this[name].(target, params*)
				       : this.__.(target, name, params*)
			}
		}
	}

	__New(arg:="") {

		this.Insert("_", []) ; proxy

		Gui, New, % "HwndhGui Label__GUI_ " arg.options
		this.handle := hGui

		for k, v in arg
			this[k] := v
	}

	__Delete() {
		
		if this.handle
			this.destroy()
		MsgBox, Yes
	}

	__Set(k, v, p*) {

		if (k = "handle") {
			if DllCall("IsWindow", "Ptr", v) {
				if (DllCall("IsWindow", "Ptr", this.handle) && this.handle<>v)
					throw Exception("ERROR", -1)
				GUI.__[v] := &this
			} else GUI.__.Remove(this.handle, "")
		}

		return this._[k] := v
	}

	class __Get extends GUI._properties_
	{

		__(k, p*) {
			if this._.HasKey(k)
				return this._[k, p*]

			return false
		}
	}

	show(options) {
		Gui, % this.handle ":Show", % options
	}

	destroy() {
		Gui, % this.handle ":Destroy"
		this.handle := false
	}

	onClose() {
		this.destroy()
		if !GUI.__.MaxIndex() {
			SetTimer, __GUI_exit, -1
			return
		}
	}

}

__GUI_get() {
	return Object(GUI.__[A_Gui])
}

__GUI_handler() {
	return

	__GUI_Close:
	__GUI_get().onClose()
	return
	
	__GUI_exit:
	ExitApp
}