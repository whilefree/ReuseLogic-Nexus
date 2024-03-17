@tool
extends VBoxContainer

#Contains a ActionEmitterControl and a Remove button
var _action_picker_control = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_controls/action_emitter_array_element.tscn")
#Used to store the Brain Signals
var _array:Array[String]

signal on_add_element(ref)
signal on_child_item_selected(array, item)
signal on_child_item_removed(array, item)

func _add_element():
	var element = _action_picker_control.instantiate()
	var signal_picker_drop_down = element.get_child(0).get_child(1)
	#The init feeds the signal_picker_drop_down with the options taken from the brain
	signal_picker_drop_down.init(_array)
	signal_picker_drop_down.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	signal_picker_drop_down.connect("on_remove", Callable(self, "_on_child_item_removed"))
	add_child(element)
	emit_signal("on_add_element",self)

#Not used in the system
func _on_child_item_removed(item):
	emit_signal("on_child_item_removed", self, item)

#Not used in the system
func _on_child_item_selected(item):
	emit_signal("on_child_item_selected", self, item)
