class_name StateHub
extends Resource

@export var brain_state:BrainStatePicker
@export var direct_state:DirectStatePicker

func _init():
	brain_state = BrainStatePicker.new()
	direct_state = DirectStatePicker.new()
