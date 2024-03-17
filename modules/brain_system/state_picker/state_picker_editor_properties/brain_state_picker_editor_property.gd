extends EditorProperty

# The main control for editing the property.
var _state_picker_control = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_controls/state_picker_drop_down.gd").new()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_classes/brain_state_picker.gd").new() as BrainStatePicker
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	var _brain = current_value.brain(obj)
	if _brain:
		#Feed the state_picker with Brain's state children
		_state_picker_control.init(current_value.states(_brain))
	else:
		push_warning("Any Node using BrainStatePicker must extend Brain or be a child of the Brain node for the BrainStatePicker to work properly.")
	
	_state_picker_control.connect("item_selected",Callable(self,"on_item_selected"))
	# Add the control as a direct child of EditorProperty node.
	add_child(_state_picker_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_state_picker_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as BrainStatePicker
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _state_picker_control.item_count:
			if new_value.state_name == _state_picker_control.get_item_text(i):
				_state_picker_control.select(i)
				#So the item_selected signal is emitted:
				_state_picker_control.selected_option = _state_picker_control.get_item_text(i)
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.state_name = _state_picker_control.get_item_text(id)
	emit_changed(get_edited_property(), current_value)
