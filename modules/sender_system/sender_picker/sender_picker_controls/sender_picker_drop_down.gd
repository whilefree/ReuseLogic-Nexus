@tool
extends OptionButton

@export var _array:Array[String]

#The SenderPicker referenced by the control
var sender_picker:SenderPicker
#The option selected in the dropdown list
var selected_option:String
#Used to make the init happen only once
var initialized = false

#Used to pass the index value to the PropertyEditor script
signal on_remove(item:SenderPicker)
signal on_item_selected(item:SenderPicker)

func init(arr:Array[String]):
	if !initialized:
		_array.append("No Sender")
		_array.append_array(arr)
		for i in _array:
			add_item(i)
		set_item_disabled(0,true)
	initialized = true

#Passing the index to the PropertyEditor, removes the element
func _remove_element():
	emit_signal("on_remove", self)
	get_parent().queue_free()

#Update selection
func _on_item_selected(id):
	selected_option = _array[id]
	emit_signal("on_item_selected", self)
