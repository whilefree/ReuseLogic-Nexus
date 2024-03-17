@tool
class_name SenderSignalPickerArray
extends Resource

@export var sender_signal_pickers:Array[SenderSignalPicker]

func remove_duplicates():
	var unique:Array[SenderSignalPicker] = []
	var temp:Array[String] = []
	for item in sender_signal_pickers:
		if not temp.has(item.sender_name):
			unique.append(item)
			temp.append(item.sender_name)
	sender_signal_pickers = unique

#Returns true if there are duplicates
func check_duplicates():
	var temp_array:Array[String] = []
	for item in sender_signal_pickers:
		temp_array.append(item.sender_name)
	if temp_array != ReuseLogicNexus.array_unique(temp_array):
		return true
	else:
		return false
