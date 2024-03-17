@tool
extends VBoxContainer

#Contains a GlobalLocalSignalPairControl and a Remove button
var _global_local_signal_pair_element = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_controls/global_local_signal_pair_array_element.tscn")
#Used to store the Brain Signals
var _array:Array[String]

signal on_add_element(ref)
signal on_child_item_selected(array, item)
signal on_child_item_removed(array, item)

func _add_element():
	var element = _global_local_signal_pair_element.instantiate()
	var global_signal_picker = element.get_child(0).get_child(0)
	#The init feeds the global_signal_picker with the options taken from the brain
	global_signal_picker.init(ReuseLogicNexus.get_signal_list())
	global_signal_picker.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	global_signal_picker.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	var signal_picker = element.get_child(0).get_child(1)
	#The init feeds the local_signal_picker with the options taken from the brain
	signal_picker.init(_array)
	signal_picker.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	signal_picker.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	add_child(element)
	emit_signal("on_add_element",self)

#Not used int he system
func _on_child_item_removed(item):
	emit_signal("on_child_item_removed", self, item)

#Not used int he system
func _on_child_item_selected(item):
	emit_signal("on_child_item_selected", self, item)
