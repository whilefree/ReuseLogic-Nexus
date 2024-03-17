@tool
extends HBoxContainer

var action_emitter:ActionEmitter

#Used to pass the index value to the PropertyEditor script
signal on_remove(item)
signal on_child_text_changed(item, text)

func _on_remove_pressed():
	emit_signal("on_remove", self)
	get_parent().queue_free()


func _on_line_edit_text_changed(new_text):
	emit_signal("on_child_text_changed", self, new_text)
