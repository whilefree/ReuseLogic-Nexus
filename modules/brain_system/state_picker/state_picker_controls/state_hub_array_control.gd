@tool
extends VBoxContainer

#Contains a BrainStateDropDown, DirectSTateDropDown and a Remove button
var _state_hub_element = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_controls/state_hub_array_element.tscn")
#Used to store all the Brain States
var _brain_states:Array[String]
#Used to store the direct State children
var _direct_states:Array[String]

signal on_add_element(ref)
signal on_child_item_selected(array, item)
signal on_child_item_removed(array, item)

func _add_element():
	var element = _state_hub_element.instantiate()
	var brain_state = element.get_child(0)
	#The init feeds the option_button with the options taken from the brain
	brain_state.init(_brain_states)
	brain_state.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	brain_state.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	var direct_state = element.get_child(1)
	#The init feeds the option_button with the options taken from the brain
	direct_state.init(_direct_states)
	direct_state.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	direct_state.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	add_child(element)
	emit_signal("on_add_element",self)

func _on_child_item_removed(item):
	emit_signal("on_child_item_removed", self, item)

func _on_child_item_selected(item):
	emit_signal("on_child_item_selected", self, item)
