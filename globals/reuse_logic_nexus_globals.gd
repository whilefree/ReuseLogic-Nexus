@tool
extends Node

@onready var global_signal_list = preload("res://addons/reuse_logic_nexus/globals/global_signal_list.tres") as GlobalSignalListResource
@onready var sender_list = preload("res://addons/reuse_logic_nexus/globals/sender_list.tres")

func _ready():
	if !Engine.is_editor_hint():
		global_signal_list.init()

# Removes duplicates from array
func array_unique(array: Array[String]) -> Array[String]:
	var unique: Array[String] = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

# Converts array to string
func array_to_string(arr: Array, separator = "") -> String:
	var s = ""
	for i in arr:
		s += str(i)+separator
	return s

#iterate up the hierarchy until you catch the first Brain
func get_brain_up(obj)->Brain:
	if obj is Brain:
		return obj
	while !obj is Brain && obj.get_parent():
		obj = obj.get_parent()
	if obj is Brain:
		return obj
	else:
		return null

#iterate down the hierarchy until you catch the first Brain
func get_brain_down(obj)->Brain:
	if obj is Brain:
		return obj
	var children = obj.get_children()
	#iterate down the hierarchy until you catch the first Brain
	for i in range(0,children.size()):
		if children[i] is Brain:
			obj = children[i]
			return obj
		else:
			continue
	return null

#Returns the sender_list Array[String] names
func get_sender_list():
	return sender_list.sender_list

#Returns the 'unique' version global_signal_list Array[String] names
func get_signal_list():
	return array_unique(global_signal_list.signal_list)
