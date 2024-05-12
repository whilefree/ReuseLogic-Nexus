@tool
class_name GlobalLocalSignalPair
extends Resource

@export var global_signal:GlobalSignalPicker = GlobalSignalPicker.new()
@export var local_signal:SignalPicker = SignalPicker.new()

#If true, the emittion of the global signal will cause the emittion of the local one
#If false, the emittion of the local signal will cause the emittion of the global one
var _global_listener_mode = true

var _brain:Brain

#new
func _init():
	resource_local_to_scene = true

func enable(brain:Brain, listener_mode = true):
	_brain = brain
	_global_listener_mode = listener_mode
	if _global_listener_mode:
		if !ReuseLogicNexus.global_signal_list.is_connected(global_signal.signal_name, Callable(self,"_raise")):
			ReuseLogicNexus.global_signal_list.connect(global_signal.signal_name, Callable(self,"_raise"))
	else:
		if !_brain.is_connected(local_signal.signal_name, Callable(self,"_raise")):
			_brain.connect(local_signal.signal_name, Callable(self,"_raise"))

func disable():
	if _global_listener_mode:
		if ReuseLogicNexus.global_signal_list.is_connected(global_signal.signal_name, Callable(self,"_raise")):
			ReuseLogicNexus.global_signal_list.disconnect(global_signal.signal_name, Callable(self,"_raise"))
	else:
		if _brain.is_connected(local_signal.signal_name, Callable(self,"_raise")):
			_brain.disconnect(local_signal.signal_name, Callable(self,"_raise"))

func _raise(data = {}):
	if _global_listener_mode:
		data["emitted_global_signal"] = global_signal.signal_name
		if local_signal:
			if _brain.has_signal(local_signal.signal_name):
				data["emitted_signal"] = local_signal.signal_name
				_brain.emit_signal(local_signal.signal_name, data)
			else:
				push_error("Trying to emit non-existing signal " + local_signal.signal_name + " owned by Brain: " + str(_brain))
	else:
		data["emitted_signal"] = local_signal.signal_name
		if global_signal:
			if ReuseLogicNexus.global_signal_list.has_signal(global_signal.signal_name):
				data["emitted_global_signal"] = global_signal.signal_name
				ReuseLogicNexus.global_signal_list.emit_signal(global_signal.signal_name, data)
			else:
				push_error("Trying to emit non-existing 'global' signal " + global_signal.signal_name)
