class_name SenderSignalPicker
extends Resource

@export var sender_name:String
@export var signal_name:String
var signal_picker:SignalPicker
var sender_picker:SenderPicker
var _brain:Brain

func brain(obj) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_up(obj)
		return _brain
	else:
		return _brain
