@tool
class_name SignalPickerGroupArray
extends Resource

@export var fake_signal_groups:Array[SignalPickerGroup]
var signal_groups:Array[SignalPickerGroup]

func _init():
	resource_local_to_scene = true

#In Godot, Resources in arrays will be shared no matter what.
#This function creates a duplicate stored in a not exported array to fix that problem.
#The not exported array must be used.
func force_local_to_scene():
	signal_groups.clear()
	for item in fake_signal_groups:
		signal_groups.append(item.duplicate(true))
