@tool
class_name GlobalLocalSignalPairArray
extends Resource

#Don't use the fake version, it's just for the inspector.
@export var fake_global_local_signal_pairs:Array[GlobalLocalSignalPair]
#This version of the array is local to scene. Use this one.
var global_local_signal_pairs:Array[GlobalLocalSignalPair]

#new
func _init():
	resource_local_to_scene = true

#In Godot, Resources in arrays will be shared no matter what.
#This function creates a duplicate stored in a not exported array to fix that problem.
#The not exported array must be used.
func force_local_to_scene():
	global_local_signal_pairs.clear()
	for item in fake_global_local_signal_pairs:
		global_local_signal_pairs.append(item.duplicate(true))

func remove_global_duplicates():
	var unique:Array[GlobalLocalSignalPair] = []
	var temp:Array[String] = []
	for item in fake_global_local_signal_pairs:
		if not temp.has(item.global_signal.signal_name):
			unique.append(item)
			temp.append(item.global_signal.signal_name)
	fake_global_local_signal_pairs = unique

func remove_local_duplicates():
	var unique:Array[GlobalLocalSignalPair] = []
	var temp:Array[String] = []
	for item in fake_global_local_signal_pairs:
		if not temp.has(item.local_signal.signal_name):
			unique.append(item)
			temp.append(item.local_signal.signal_name)
	fake_global_local_signal_pairs = unique

#Returns true if there are duplicates in the global list
func check_global_duplicates() -> bool:
	var temp_array:Array[String] = []
	for item in fake_global_local_signal_pairs:
		temp_array.append(item.global_signal.signal_name)
	if temp_array != ReuseLogicNexus.array_unique(temp_array):
		return true
	else:
		return false

#Returns true if there are duplicates in the local list
func check_local_duplicates() -> bool:
	var temp_array:Array[String] = []
	for item in fake_global_local_signal_pairs:
		temp_array.append(item.local_signal.signal_name)
	if temp_array != ReuseLogicNexus.array_unique(temp_array):
		return true
	else:
		return false
