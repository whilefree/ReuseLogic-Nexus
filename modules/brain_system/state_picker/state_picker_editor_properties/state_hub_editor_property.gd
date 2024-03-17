extends EditorProperty

# The main control for editing the property.
var _state_hub_control = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_controls/state_hub_element.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_classes/state_hub.gd").new() as StateHub
# A guard against internal changes when the property is updated.
var updating = false

var _brain_state
var _direct_state

func _init(obj = null, prop = null):
	_brain_state = _state_hub_control.get_child(0)
	_direct_state = _state_hub_control.get_child(1)
	
	_brain_state.init(current_value.brain_state.states(obj))
	_direct_state.init(current_value.direct_state.states(obj))
	
	_brain_state.connect("item_selected",Callable(self,"on_brain_item_selected"))
	_direct_state.connect("item_selected",Callable(self,"on_direct_item_selected"))
	
	# Add the control as a direct child of EditorProperty node.
	add_child(_state_hub_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_state_hub_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as StateHub
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _brain_state.item_count:
			if new_value.brain_state.state_name == _brain_state.get_item_text(i):
				_brain_state.select(i)
				#So the item_selected signal is emitted:
				_brain_state.selected_option = _brain_state.get_item_text(i)
		
		for i in _direct_state.item_count:
			if new_value.direct_state.state_name == _direct_state.get_item_text(i):
				_direct_state.select(i)
				#So the item_selected signal is emitted:
				_direct_state.selected_option = _direct_state.get_item_text(i)
				
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_brain_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.brain_state.state_name = _brain_state.get_item_text(id)
	emit_changed(get_edited_property(), current_value)

func on_direct_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.direct_state.state_name = _direct_state.get_item_text(id)
	emit_changed(get_edited_property(), current_value)
