@icon("res://addons/reuse_logic_nexus/icons/BrainState.png")
@tool
class_name BrainState
extends Node

var _brain:Brain

@export var state_hub_list:StateHubArray

##The delay time before Raise on Start signals are emitted and _process and _physics_process are activated
@export var start_delay:float = 0
##The signal used to switch to this state
@export var start_state_on:SignalPicker
##Adds the signal name in the field below to the Brain parent
@export var add_start_signal:bool:
	get:
		return add_start_signal
	set(value):
		if start_signal_name:
			brain(self).add_state_signal(start_signal_name)
			if !start_state_on:
				start_state_on = SignalPicker.new()
			start_state_on.signal_name = start_signal_name
			start_signal_name = ""
			notify_property_list_changed()

##After entering the signal name, click the button above to add it to the Brain
@export var start_signal_name:String = ""

@export_group("Raise on Start")
##The signals to be emitted when the state is activated
@export var raise_on_start:SignalPickerArray

@export_group("Raise on Process")
##The signals to be emitted in the _process function
@export var raise_on_process:SignalPickerArray

@export_group("Raise on Physics Process")
##The signals to be emitted in the _physics_process function
@export var raise_on_physics_process:SignalPickerArray

@export_group("Raise on Listen")
##The signal pairs: Listen to 1 signal and emit an array of signals in return
@export var raise_on_listen:SignalPickerGroupArray

# used to start the state activation on delay
var tween:Tween
# check = 0 means the state is inactive and nothing will happen
# check = 1 means state is just activated and raise_on_start should be emitted
# check = 2 means raise_on_start has been emitted and process and physics_process should be activated
var check

func _ready():
	#Must be called to force resource_local_to_scene in the array
	#In Godot resources in arrays are shared, no matter what.
	if raise_on_listen:
		raise_on_listen.force_local_to_scene()
	
	brain(self)
	if _brain:
		if start_state_on:
			if !Engine.is_editor_hint():
				_brain.connect(start_state_on.signal_name, Callable(self, "switch_state"))
	else:
		push_error("BrainStates must be direct/indirect children of the Brain node. Otherwise they won't work properly.")
	
func brain(obj) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_up(obj)
		return _brain
	else:
		return _brain

func start_state():
	if raise_on_listen:
		for g in raise_on_listen.signal_groups:
			if g:
				g.enable(_brain, self)
	check = 0

func initialize_tween():
	tween = create_tween()
	if start_delay > 0:
		tween.tween_callback(raise_start_signals).set_delay(start_delay)
	else:
		tween.tween_callback(raise_start_signals)

func raise_start_signals():
	if _brain.debug:
		print_rich("[color=green]" + name + "[/color] " + "started!")
	start_state()
	check = 1
	if raise_on_start:
		for i in raise_on_start.signal_pickers:
			if i.signal_name:
				var _data = {
					"current_state" : self,
					"brain" : _brain,
					"emitted_signal" : i.signal_name,
				}
				_brain.emit_signal(i.signal_name, _data)

func stop_state(): 
	check = 0
	if tween:
		tween.kill()
	if raise_on_listen:
		for g in raise_on_listen.signal_groups:
			if g:
				g.disable()

func switch_state(_data = {}):
	_data["new_state"] = self
	_brain.switch_state(_data)

func process(delta):
	if check == 1:
		check = 2
	
	if check == 2:
		if raise_on_process:
			for i in raise_on_process.signal_pickers:
				if i.signal_name:
					var _data = {
						"current_state" : self,
						"brain" : _brain,
						"emitted_signal" : i.signal_name,
					}
					_brain.emit_signal(i.signal_name, _data)
		#print(name + ": process")

func physics_process(delta):
	if check == 1:
		check = 2
	
	if check == 2:
		if raise_on_physics_process:
			for i in raise_on_physics_process.signal_pickers:
				if i.signal_name:
					var _data = {
						"current_state" : self,
						"brain" : _brain,
						"emitted_signal" : i.signal_name,
					}
					_brain.emit_signal(i.signal_name, _data)
		#print(name + ": physics_process")
