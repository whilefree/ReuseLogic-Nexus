@tool
extends VBoxContainer

#Contains a SignalPickerDropDown and a Remove button
var _signal_picker_element = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_controls/signal_picker_array_element.tscn")
#Used to store the Brain Signals
var _array:Array[String]

signal on_add_element(ref)
signal on_child_item_selected(array, item)
signal on_child_item_removed(array, item)

func _add_element():
	var element = _signal_picker_element.instantiate()
	var option_button = element.get_child(0)
	#The init feeds the option_button with the options taken from the brain
	option_button.init(_array)
	option_button.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	option_button.connect("on_remove", Callable(self, "_on_child_item_removed"))
	add_child(element)
	emit_signal("on_add_element",self)

func _on_child_item_removed(item):
	emit_signal("on_child_item_removed", self, item)

func _on_child_item_selected(item):
	emit_signal("on_child_item_selected", self, item)
