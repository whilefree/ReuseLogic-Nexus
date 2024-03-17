@tool
class_name GlobalLocalSignalPairArray
extends Resource

@export var global_local_signal_pairs:Array[GlobalLocalSignalPair]

func remove_global_duplicates():
	var unique:Array[GlobalLocalSignalPair] = []
	var temp:Array[String] = []
	for item in global_local_signal_pairs:
		if not temp.has(item.global_signal.signal_name):
			unique.append(item)
			temp.append(item.global_signal.signal_name)
	global_local_signal_pairs = unique

func remove_local_duplicates():
	var unique:Array[GlobalLocalSignalPair] = []
	var temp:Array[String] = []
	for item in global_local_signal_pairs:
		if not temp.has(item.local_signal.signal_name):
			unique.append(item)
			temp.append(item.local_signal.signal_name)
	global_local_signal_pairs = unique

#Returns true if there are duplicates in the global list
func check_global_duplicates() -> bool:
	var temp_array:Array[String] = []
	for item in global_local_signal_pairs:
		temp_array.append(item.global_signal.signal_name)
	if temp_array != ReuseLogicNexus.array_unique(temp_array):
		return true
	else:
		return false

#Returns true if there are duplicates in the local list
func check_local_duplicates() -> bool:
	var temp_array:Array[String] = []
	for item in global_local_signal_pairs:
		temp_array.append(item.local_signal.signal_name)
	if temp_array != ReuseLogicNexus.array_unique(temp_array):
		return true
	else:
		return false
