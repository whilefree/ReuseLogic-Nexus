@icon("res://addons/reuse_logic_nexus/icons/Brain.png")
@tool
class_name Brain
extends Node

# List of valid errors used by _error (for inspector warnings)
enum {
	DUPLICATES = 1, 
	}

# Used to handle the warning system in the inspector
var _error = 0

# Used to make the duplicate warning notify happen only once, allowing the user to continue working with the inspector even if there are duplicates.
var _duplicate_show = false

##If enabled, state transitions will be printed
@export var debug:bool = false

##Removes duplicate entries
var _remove_duplicates:bool = false:
	set(value):
		_remove_duplicates = false
		_signal_list = ReuseLogicNexus.array_unique(_signal_list)
		_error = 0
		update_configuration_warnings()

##The names of the signals used by the brain and its children.
var _signal_list:Array[String]:
	get:
		signal_list_resource.signal_list = _signal_list
		return _signal_list
	set(value):
		_signal_list = value
		_refresh_signals(_signal_list)
		signal_list_resource.signal_list = _signal_list
		notify_property_list_changed()

@export var initial_state:DirectStatePicker
var current_state:BrainState
var state_list:Array[BrainState]

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
				if !_signal_list.has(item):
					_signal_list.append(item)
					notify_property_list_changed()

var tween:Tween

func _ready():
	if !Engine.is_editor_hint():
		if initial_state:
			state_list = initial_state.states_as_nodes(self)
			for s in state_list:
				if s.name == initial_state.state_name:
					current_state = s
			tween = create_tween()
			tween.tween_callback(initialize_state_tween)

func initialize_state_tween():
	current_state.initialize_tween()

func _process(delta):
	if !Engine.is_editor_hint() && current_state:
		current_state.process(delta)

func _physics_process(delta):
	if !Engine.is_editor_hint() && current_state:
		current_state.physics_process(delta)

#State must go into the data dictionary
func switch_state(_data = {}):
	if tween:
		tween.kill()
	var old_state = current_state
	current_state.stop_state()
	#Skipping the state if it has state_hub_list which matches the old_state
	if _data["new_state"].state_hub_list:
		for s in _data["new_state"].state_hub_list.state_hubs:
			if s.brain_state.state_name == old_state.name:
				for ch in _data["new_state"].get_children():
					if ch.name == s.direct_state.state_name:
						ch.switch_state(_data)
						return
	if debug:
		print_rich("State is switching from: [color=green]" + old_state.name + "[/color] to: [color=green]" + _data["new_state"].name + " [/color]")
	current_state = _data["new_state"]
	tween = create_tween()
	tween.tween_callback(initialize_state_tween)

func register_signal(signal_picker, callable:Callable):
	if signal_picker:
		connect(signal_picker.signal_name, callable)

#Intented to be called by Child States, it adds a signal_name to the Signal List as the first entry
func add_state_signal(signal_name):
	if !_signal_list.has(signal_name):
		_signal_list.push_front(signal_name)

#Creates a dictionary containing signal names and signals: key = signal name - value = signal itself
func _refresh_signals(arr):
	if !Engine.is_editor_hint():
		for s in _signal_list:
			if !has_signal(s) && s:
				add_user_signal(s)

#Gets the unique list of signal names stored in _signal_list array
func get_signal_names() -> Array[String]:
	return ReuseLogicNexus.array_unique(_signal_list)

#-------------- inspector stuff --------------#

func _get_property_list() -> Array:
	var properties = []
	
	if _error == DUPLICATES:
		properties.append({
			"name": "_remove_duplicates",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		
	properties.append({
		"name": "_signal_list",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d:" % [TYPE_STRING]
	})
	update_configuration_warnings()
	return properties

func _get_configuration_warnings():
	var warnings = PackedStringArray()
	if _signal_list != ReuseLogicNexus.array_unique(_signal_list):
		warnings.append("There are duplicate entries in the 'Signal List'. Click on 'Remove Duplicates' button to fix the problem. Duplicates are ignored by SignalPicker property type by default.")
		_error = DUPLICATES
		if !_duplicate_show:
			notify_property_list_changed()
			_duplicate_show = true
	else:
		if _duplicate_show:
			notify_property_list_changed()
		_duplicate_show = false
		_error = 0
	
	var children = find_children("","Receiver")
	if children.size() > 1:
		warnings.append("You are not supposed to use 2 Receivers in the same system. Consider removing the duplicate(s).")
	return warnings
