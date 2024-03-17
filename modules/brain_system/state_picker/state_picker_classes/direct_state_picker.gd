class_name DirectStatePicker
extends Resource

@export var state_name:String

#Lists the direct child state names as an array of strings
func states(obj:Node)->Array[String]:
	var array:Array[String] = []
	var children = obj.get_children()
	for i in children:
		if i is BrainState:
			array.append(i.name)
	return array

#Lists the direct child states as an array of nodes
func states_as_nodes(obj:Node)->Array[BrainState]:
	var array:Array[BrainState] = []
	var children = obj.get_children()
	for i in children:
		if i is BrainState:
			array.append(i)
	return array
