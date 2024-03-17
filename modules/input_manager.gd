@icon("res://addons/reuse_logic_nexus/icons/InputManager.png")
class_name InputManager
extends Node

@export_group("_input")
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _input function when pressed.
@export var _input_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _input function when pressed (happens once).
@export var _input_just_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _input function when released.
@export var _input_released:ActionEmitterArray

@export_group("_unhandled_input")
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_input function when pressed.
@export var _unhandled_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_input function when pressed (happens once).
@export var _unhandled_just_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_input function when released.
@export var _unhandled_released:ActionEmitterArray

@export_group("_unhandled_key_input")
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_key_input function when pressed.
@export var _unhandled_key_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_key_input function when pressed (happens once).
@export var _unhandled_key_just_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _unhandled_key_input function when released.
@export var _unhandled_key_released:ActionEmitterArray

@export_group("_process")
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _process function when pressed.
@export var _process_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _process function when pressed (happens once).
@export var _process_just_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _process function when released.
@export var _process_released:ActionEmitterArray

@export_group("_physics_process")
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _physics_process function when pressed.
@export var _physics_process_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _physics_process function when pressed (happens once).
@export var _physics_process_just_pressed:ActionEmitterArray
## The Input Actions defined in the Project Settings Input Map section; they will be emitted automatically in _physics_process function when released.
@export var _physics_process_released:ActionEmitterArray

func _input(event):
	emit_signals_pressed(_input_pressed, event, true)
	emit_signals_pressed(_input_just_pressed, event)
	emit_signals_released(_input_released, event)

func _unhandled_input(event):
	emit_signals_pressed(_unhandled_pressed, event, true)
	emit_signals_pressed(_unhandled_just_pressed, event)
	emit_signals_released(_unhandled_released, event)

func _unhandled_key_input(event):
	emit_signals_pressed(_unhandled_key_pressed, event, true)
	emit_signals_pressed(_unhandled_key_just_pressed, event)
	emit_signals_released(_unhandled_key_released, event)

func _process(_delta):
	emit_signals_pressed(_process_pressed, null, true)
	emit_signals_pressed(_process_just_pressed)
	emit_signals_released(_process_released)
	
func _physics_process(_delta):
	emit_signals_pressed(_physics_process_pressed, null, true)
	emit_signals_pressed(_physics_process_just_pressed)
	emit_signals_released(_physics_process_released)

func emit_signals_just_pressed(array:ActionEmitterArray, event = null):
		if array:
			for i in array.action_emitters:
				if event:
					if event.is_action_pressed(i.action_name):
						i.brain(self).emit_signal(i.signal_name, {"action_just_pressed" : i.action_name, "emitted_signal" : i.signal_name})
				else:
					if Input.is_action_pressed(i.action_name):
						i.brain(self).emit_signal(i.signal_name, {"action_just_pressed" : i.action_name, "emitted_signal" : i.signal_name})

func emit_signals_pressed(array:ActionEmitterArray, event = null, echo = false):
		if array:
			for i in array.action_emitters:
				if event:
					if event.is_action_pressed(i.action_name, echo):
						i.brain(self).emit_signal(i.signal_name, {"action_pressed" : i.action_name, "emitted_signal" : i.signal_name})
				else:
					if echo:
						if Input.is_action_pressed(i.action_name):
							i.brain(self).emit_signal(i.signal_name, {"action_pressed" : i.action_name, "emitted_signal" : i.signal_name})
					else:
						if Input.is_action_just_pressed(i.action_name):
							i.brain(self).emit_signal(i.signal_name, {"action_just_pressed" : i.action_name, "emitted_signal" : i.signal_name})

func emit_signals_released(array:ActionEmitterArray, event = null):
	if array:
		for i in array.action_emitters:
				if event:
					if event.is_action_released(i.action_name):
						i.brain(self).emit_signal(i.signal_name, {"action_released" : i.action_name, "emitted_signal" : i.signal_name})
				else:
					if Input.is_action_just_released(i.action_name):
						i.brain(self).emit_signal(i.signal_name, {"action_released" : i.action_name, "emitted_signal" : i.signal_name})
