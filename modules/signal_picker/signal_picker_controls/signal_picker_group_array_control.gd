@tool
extends VBoxContainer

#Contains a SignalPickerGroup and a Remove button
var _signal_picker_group = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_controls/signal_picker_group_array_element.tscn")
#Used to store the Brain Signals
var _array:Array[String]

signal on_child_item_added(group, array)
signal on_child_item_selected(group,array,item)
signal on_child_item_removed(group,array,item)

func _add_element():
	var element = _signal_picker_group.instantiate()
	var signal_picker_group_control = element.get_child(0)
	var signal_to_listen = signal_picker_group_control.get_child(0)
	var signals_to_raise = signal_picker_group_control.get_child(1)
	#The init feeds the signal_to_listen with the options taken from the brain
	signal_to_listen.init(_array)
	#Feeds the signals_to_raise with the options taken from the brain
	signals_to_raise._array = _array
	signals_to_raise.connect("on_add_element",Callable(self,"_on_add_array_element"))
	signals_to_raise.connect("on_child_item_selected", Callable(self, "_on_array_item_selected"))
	signals_to_raise.connect("on_child_item_removed", Callable(self, "_on_array_item_removed"))
	add_child(element)

func _on_array_item_removed(array, item):
	var children = get_children()
	children.remove_at(0)
	for i in range(0,children.size()):
		if children[i].get_child(0).get_child(1) == array:
			emit_signal("on_child_item_removed", children[i].get_child(0), array, item)

func _on_array_item_selected(array, item):
	var children = get_children()
	children.remove_at(0)
	for i in range(0,children.size()):
		if children[i].get_child(0).get_child(1) == array:
			emit_signal("on_child_item_selected",children[i].get_child(0), array, item)

func _on_add_array_element(array):
	var children = get_children()
	children.remove_at(0)
	for i in range(0,children.size()):
		if children[i].get_child(0).get_child(1) == array:
			emit_signal("on_child_item_added",children[i].get_child(0), array)
