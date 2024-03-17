@icon("res://addons/reuse_logic_nexus/icons/Receiver.png")
@tool
class_name Receiver
extends Node

var _brain:Brain

# Used to make the duplicate warning notify happen only once, allowing the user to continue working with the inspector even if there are duplicates.
var _duplicate_show = false

## Removes duplicate entries
var _remove_duplicates:bool = false:
	set(value):
		_remove_duplicates = false
		sender_list.remove_duplicates()
		_duplicate_show = false
		update_configuration_warnings()
		notify_property_list_changed()

##If enabled, the Sender and Receiver information will be printed.
@export var debug:bool = false
##List of Sender/Signal Pairs. If the Sender type matches the Send message received, the signal selected will be emitted.
@export var sender_list:SenderSignalPickerArray

func _ready():
	var temp = get_parent()
	if !temp is Brain:
		push_warning("The Receiver Module must be a direct child of The Brain Node.")
	else:
		_brain = temp

#Adds a new Sender Type attached to the signal_name to the Receiver
func add_sender_type(sender_name, signal_name):
	#Check if there isn't a duplicate of sender_name in the array
	for item in sender_list.sender_signal_pickers:
		if item.sender_name == sender_name:
			push_error("Trying to add duplicate Sender Type '" + sender_name + "' to Receiver. Addition ignored.")
			return
	var temp = SenderSignalPicker.new()
	temp.sender_name = sender_name
	temp.signal_name = signal_name
	sender_list.sender_signal_pickers.append(temp)

#Removes the Sender Type named sender_name from the Receiver
func remove_sender_type(sender_name):
	#Check if the Sender Type exists in the array
	var temp
	for item in sender_list.sender_signal_pickers:
		if item.sender_name == sender_name:
			temp = item.sender_name
	if !temp:
		push_error("Trying to remove non-existing Sender Type '" + sender_name + "' from Receiver. Deletion ignored.")
		return
	
	for i in range(0,sender_list.sender_signal_pickers.size()):
		if sender_list.sender_signal_pickers[i].sender_name == sender_name:
			sender_list.sender_signal_pickers.remove_at(i)
			return

#Changes the signal attached to the Sender Type named sender_name to the new signal_name
func change_signal(sender_name, signal_name):
	#Check if the sender_name specified does exist in the array
	var temp
	for item in sender_list.sender_signal_pickers:
		if item.sender_name == sender_name:
			temp = item.sender_name
	if !temp:
		push_error("Trying to change the Signal attached to non-existing Sender Type '" + sender_name + "' in Receiver. Change ignored.")
		return
		
	for item in sender_list.sender_signal_pickers:
		if item.sender_name == sender_name:
			item.signal_name = signal_name

func receive(data = {}):
	if debug:
		print_rich("Sender of type: [color=yellow]" + data["sender_type"] + "[/color] sent a message from object: [color=yellow]" + data["sender_owner"].name + "[/color]")
	#erasing the unnecessary information from the sender:
	var new_data = {}
	new_data["sender_type"] = data["sender_type"]
	new_data["sender_owner"] = data["sender_owner"]
	new_data["sender"] = data["sender"]
	new_data["receiver"] = self
	for item in sender_list.sender_signal_pickers:
		if item.sender_name == data["sender_type"]:
			_brain.emit_signal(item.signal_name, new_data)

func received(data):
	data["receiver_owner"] = owner
	data["sender"].received(data)

func _get_property_list() -> Array:
	var properties = []
	if _duplicate_show:
		properties.append({
			"name": "_remove_duplicates",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	return properties

func _get_configuration_warnings():
	var warnings = []
	if sender_list && sender_list.check_duplicates():
		warnings.append("There are duplicate entries in the 'Sender List'. There must be no duplicates of 'Sender Types' inside the 'Sender list'. Remove the duplicates or you may get unexpected behaviour.")
		_duplicate_show = true
		notify_property_list_changed()
	else:
		if _duplicate_show:
			notify_property_list_changed()
		_duplicate_show = false
	if !get_parent() is Brain:
		warnings.append("The Receiver Module must be a direct child of the Brain node to work properly.")
	return warnings
