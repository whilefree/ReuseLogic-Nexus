class_name SignalPickerGroup
extends Resource

@export var signal_to_listen:SignalPicker = SignalPicker.new()
@export var signals_to_raise:Array[SignalPicker]

var _brain:Brain
var _state:BrainState

func enable(brain:Brain, state:BrainState):
	_brain = brain
	_state = state
	if !_brain.is_connected(signal_to_listen.signal_name, Callable(self,"_raise_all")):
		_brain.connect(signal_to_listen.signal_name, Callable(self,"_raise_all"))

func disable():
	if _brain.is_connected(signal_to_listen.signal_name, Callable(self,"_raise_all")):
		_brain.disconnect(signal_to_listen.signal_name, Callable(self,"_raise_all"))

func _raise_all(data = {}):
	data["brain"] = _brain
	data["current_state"] = _state
	if signals_to_raise:
		for i in signals_to_raise:
			if _brain.has_signal(i.signal_name):
				data["emitted_signal"] = i.signal_name
				_brain.emit_signal(i.signal_name, data)
			else:
				push_error("Trying to emit non-existing signal " + i.signal_name + " owned by Brain: " + str(_brain))
