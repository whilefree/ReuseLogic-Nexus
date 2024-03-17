@tool
class_name GlobalSignalListResource
extends Resource

var signal_list:Array[String]:
	get:
		signal_list_resource.signal_list = signal_list
		return signal_list
	set(value):
		signal_list = value
		_refresh_signals(signal_list)
		signal_list_resource.signal_list = signal_list
		notify_property_list_changed()

## Removes duplicate entries
var _remove_duplicates:bool = false:
	set(value):
		_remove_duplicates = false
		if Engine.is_editor_hint():
			signal_list = ReuseLogicNexus.array_unique(signal_list)

##Used to make a backup or use a backup signal list stored as a resource in the project files
@export var signal_list_resource:SignalList:
	get:
		if !signal_list_resource:
			signal_list_resource = SignalList.new()
		return signal_list_resource
	set(value):
		signal_list_resource = SignalList.new()
		if value:
			for item in value.signal_list:
				if !signal_list.has(item):
					signal_list.append(item)
					notify_property_list_changed()

func init():
	_refresh_signals(signal_list)

#Creates a dictionary containing signal names and signals: key = the signal name | value = the signal itself
func _refresh_signals(arr):
	if !Engine.is_editor_hint():
		for s in signal_list:
			if !has_signal(s) && s:
				add_user_signal(s)

func _get_property_list() -> Array:
	var properties = []
	
	if signal_list != ReuseLogicNexus.array_unique(signal_list):
		properties.append({
			"name": "_remove_duplicates",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		
	properties.append({
		"name": "signal_list",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d:" % [TYPE_STRING]
	})
	return properties
