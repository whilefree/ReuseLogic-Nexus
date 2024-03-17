class_name ActionEmitter
extends Resource

@export var signal_name:String
@export var action_name:String
#var signal_picker:SignalPicker
var _brain:Brain

#Not used in the system
func get_input_map_actions() -> Array[String]:
	var array:Array[String] = []
	for action in InputMap.get_actions():
		if action.begins_with("ui"):
			continue
		else:
			array.append(action)
	return array

func brain(pass_self) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_up(pass_self)
		return _brain
	else:
		return _brain
