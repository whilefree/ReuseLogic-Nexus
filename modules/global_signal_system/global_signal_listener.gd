@tool
@icon("res://addons/reuse_logic_nexus/icons/GlobalSignalListener.png")
class_name GlobalSignalListener
extends Node

var _brain:Brain

# Used to make the duplicate warning notify happen only once, allowing the user to continue working with the inspector even if there are duplicates.
var _duplicate_show = false

##Removes duplicate entries
var _remove_duplicates:bool = false:
	set(value):
		_remove_duplicates = false
		signal_list.remove_global_duplicates()
		_duplicate_show = false
		update_configuration_warnings()
		notify_property_list_changed()

@export var signal_list:GlobalLocalSignalPairArray = GlobalLocalSignalPairArray.new()

func _ready():
	var temp = ReuseLogicNexus.get_brain_up(self)
	if !temp is Brain:
		push_warning("The GlobalSignalListener Module must be a child of The Brain Node.")
	else:
		_brain = temp
	if !Engine.is_editor_hint():
		enable_signals()

func enable_signals():
	if signal_list:
		for item in signal_list.global_local_signal_pairs:
			if item:
				item.enable(_brain)

func disable_signals():
	if signal_list:
		for item in signal_list.global_local_signal_pairs:
			if item:
				item.disable()

#Adds a new signal pair. Enables it by default.
func add_signal_pair(global_signal_name, signal_name, enable = true):
	#Check if there isn't a duplicate of global_signal_name in the array
	for item in signal_list.global_local_signal_pairs:
		if item.global_signal.signal_name == global_signal_name:
			push_error("Trying to add duplicate GlobalSignal '" + global_signal_name + "' to the Listener Module. Addition ignored.")
			return
	var temp = GlobalLocalSignalPair.new()
	temp.global_signal.signal_name = global_signal_name
	temp.local_signal.signal_name = signal_name
	if enable:
		temp.enable(_brain)
	signal_list.global_local_signal_pairs.append(temp)

#Removes and disables the signal pair containing global_signal_name from the Listener Module.
func remove_signal_pair(global_signal_name):
	#Check if the global_signal_name exists in the array
	var temp
	for item in signal_list.global_local_signal_pairs:
		if item.global_signal.signal_name == global_signal_name:
			temp = global_signal_name
	if !temp:
		push_error("Trying to remove non-existing GlobalSignal '" + global_signal_name + "' from the Listener Module. Deletion ignored.")
		return
	
	for i in range(0,signal_list.global_local_signal_pairs.size()):
		if signal_list.global_local_signal_pairs[i].global_signal.signal_name == global_signal_name:
			signal_list.global_local_signal_pairs[i].disable()
			signal_list.global_local_signal_pairs.remove_at(i)
			return

#Changes the local signal attached to the global signal named global_signal_name to the new signal_name
func change_signal(global_signal_name, signal_name):
	#Check if the global_signal_name specified does exist in the array
	var temp
	for item in signal_list.global_local_signal_pairs:
		if item.global_signal.signal_name == global_signal_name:
			temp = global_signal_name
	if !temp:
		push_error("Trying to change the Signal attached to non-existing GlobalSignal '" + global_signal_name + "' in the Listener Module. Change ignored.")
		return
		
	for item in signal_list.global_local_signal_pairs:
		if item.global_signal.signal_name == global_signal_name:
			item.local_signal.signal_name = signal_name
			item.disable()
			item.enable(_brain)

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
	if signal_list.check_global_duplicates():
		warnings.append("There are duplicate entries in the 'Signal List'. There must be no duplicates of 'Global Signals' inside the 'Signal List'. This is against the OOP principles maintained by ReuseLogicNexus and also may cause unexpected behavior.")
		_duplicate_show = true
		notify_property_list_changed()
	else:
		if _duplicate_show:
			notify_property_list_changed()
		_duplicate_show = false
	if !ReuseLogicNexus.get_brain_up(self) is Brain:
		warnings.append("The GlobalSignalListener Module must be a child of the Brain node to work properly.")
	return warnings
