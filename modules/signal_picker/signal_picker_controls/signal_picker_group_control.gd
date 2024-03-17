@tool
extends VBoxContainer

#The SignalPickerGroup referenced by the control
var signal_picker_group:SignalPickerGroup

#Used to pass the index value to the PropertyEditor script
signal on_remove(item:SignalPickerGroup)

#Passing the item to the PropertyEditor, removes the element
func _remove_element():
	emit_signal("on_remove", signal_picker_group)
	get_parent().queue_free()
