class_name SignalPicker
extends Resource

@export var signal_name:String
var _brain:Brain

func brain(pass_signal_picker_owner) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_up(pass_signal_picker_owner)
		return _brain
	else:
		return _brain
