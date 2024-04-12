class_name SignalPickerSibling
extends Resource

@export var signal_name:String
var _brain:Brain

func brain(pass_signal_picker_owner) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_sibling(pass_signal_picker_owner)
		return _brain
	else:
		return _brain
