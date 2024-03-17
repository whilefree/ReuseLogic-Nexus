@tool
extends HBoxContainer

var global_local_signal_picker_pair:GlobalLocalSignalPair

#Used to pass the index value to the PropertyEditor script
signal on_remove(item)
signal on_child_text_changed(item, text)

func _on_remove_pressed():
	emit_signal("on_remove", self)
	get_parent().queue_free()
