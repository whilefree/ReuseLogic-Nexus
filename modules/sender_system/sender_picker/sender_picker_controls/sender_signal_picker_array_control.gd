@tool
extends VBoxContainer

#Contains a SignalSenderPickerControl and a Remove button
var _sender_signal_picker_element = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_controls/sender_signal_picker_array_element.tscn")
#Used to store the Brain Signals
var _array:Array[String]

signal on_add_element(ref)
signal on_child_item_selected(array, item)
signal on_child_item_removed(array, item)

func _add_element():
	var element = _sender_signal_picker_element.instantiate()
	var sender_picker = element.get_child(0).get_child(0)
	#The init feeds the sender_picker with the options taken from the brain
	sender_picker.init(ReuseLogicNexus.get_sender_list())
	sender_picker.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	sender_picker.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	var signal_picker = element.get_child(0).get_child(1)
	#The init feeds the signal_picker with the options taken from the brain
	signal_picker.init(_array)
	signal_picker.connect("on_item_selected", Callable(self, "_on_child_item_selected"))
	signal_picker.connect("on_remove", Callable(self, "_on_child_item_removed"))
	
	add_child(element)
	emit_signal("on_add_element",self)

func _on_child_item_removed(item):
	emit_signal("on_child_item_removed", self, item)

func _on_child_item_selected(item):
	emit_signal("on_child_item_selected", self, item)
