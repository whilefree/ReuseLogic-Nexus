@tool
extends OptionButton

@export var _array:Array[String]

#The GlobalSignalPicker referenced by the control
var global_signal_picker:GlobalSignalPicker
#The option selected in the dropdown list
var selected_option:String
#Used to make the init happen only once
var initialized = false

#Used to pass the index value to the PropertyEditor script
signal on_remove(item:GlobalSignalPicker)
signal on_item_selected(item:GlobalSignalPicker)

func init(arr:Array[String]):
	if !initialized:
		_array.append("No Signal")
		_array.append_array(arr)
		for i in _array:
			add_item(i)
		set_item_disabled(0,true)
	initialized = true

#Passing the index to the PropertyEditor, removes the GlobalSignalPickerArrayElement
func _remove_element():
	emit_signal("on_remove", self)
	get_parent().queue_free()

#Update selection
func _on_item_selected(id):
	selected_option = _array[id]
	emit_signal("on_item_selected", self)
