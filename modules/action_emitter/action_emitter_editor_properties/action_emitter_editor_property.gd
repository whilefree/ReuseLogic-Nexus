extends EditorProperty

# The main control for editing the property.
var _action_emitter_control = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_controls/action_emitter_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_classes/action_emitter.gd").new() as ActionEmitter
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	var _brain = current_value.brain(obj)
	if _brain:
		#Feed the action_emitter with Brain's signal names
		_action_emitter_control.get_child(1).init(_brain.get_signal_names())
	else:
		push_warning("Any Node using ActionEmitter must be a child of the Brain node for the ActionEmitter to work properly.")
	_action_emitter_control.get_child(1).connect("item_selected",on_item_selected)
	_action_emitter_control.get_child(0).connect("text_changed",on_text_changed)
	# Add the control as a direct child of EditorProperty node.
	add_child(_action_emitter_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_action_emitter_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as ActionEmitter
		if !_action_emitter_control.get_child(0).text:
			_action_emitter_control.get_child(0).text = new_value.action_name
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _action_emitter_control.get_child(1).item_count:
			if new_value.signal_name == _action_emitter_control.get_child(1).get_item_text(i):
				_action_emitter_control.get_child(1).select(i)
				#So the item_selected signal is emitted:
				_action_emitter_control.get_child(1).selected_option = _action_emitter_control.get_child(1).get_item_text(i)
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.signal_name = _action_emitter_control.get_child(1).get_item_text(id)
	emit_changed(get_edited_property(), current_value)

func on_text_changed(text):
	current_value.action_name = (_action_emitter_control.get_child(0) as LineEdit).text
	emit_changed(get_edited_property(), current_value)
