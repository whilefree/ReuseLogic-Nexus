class_name BrainStatePicker
extends Resource

@export var state_name:String
var _brain:Brain

func states(obj:Node)->Array[String]:
	var array:Array[String] = []
	var children = _get_all_children(brain(obj))
	for i in children:
		if i is BrainState:
			array.append(i.name)
	return array

func brain(obj) -> Brain:
	if !_brain:
		_brain = ReuseLogicNexus.get_brain_up(obj)
		return _brain
	else:
		return _brain

func _get_all_children(obj) -> Array:
	var array : Array = []
	for i in obj.get_children():
		if i.get_child_count() > 0:
			array.append(i)
			array.append_array(_get_all_children(i))
		else:
			array.append(i)

	return array
