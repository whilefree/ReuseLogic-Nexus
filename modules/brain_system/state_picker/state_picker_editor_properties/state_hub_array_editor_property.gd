extends EditorProperty

# The main control for editing the property.
var _state_picker_array_control = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_controls/state_hub_array_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_classes/state_hub_array.gd").new()
var _brain:Brain
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	var _direct_states = DirectStatePicker.new().states(obj)
	var _brain_states = BrainStatePicker.new().states(obj)
	_brain = BrainStatePicker.new().brain(obj)

	_state_picker_array_control._brain_states = _brain_states
	_state_picker_array_control._direct_states = _direct_states
	
	#connect AddElement button signal:
	_state_picker_array_control.get_child(0).connect("pressed", Callable(self, "on_add_element"))
	
	if prop:
		current_value = prop
	
	recreate_drop_down_list(current_value.state_hubs)
	refresh_drop_down_list()
	# Add the control as a direct child of EditorProperty node.
	add_child(_state_picker_array_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_state_picker_array_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	if new_value:
		current_value = new_value
	updating = false

#Synchronizes the elements and the internal property upon the creation of an element
func on_add_element():
	if !_brain:
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the StateHubArray
		push_warning("Any Node using StateHubArray must be a child of the Brain node for the StateHubArray to work properly.")
	if updating:
		return
	current_value.state_hubs.append(StateHub.new())
	emit_changed(get_edited_property(), current_value)
	refresh_drop_down_list()

#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_element(item):
	var temp_index = 0
	for i in range(0, current_value.state_hubs.size()):
		if current_value.state_hubs[i].direct_state == item.state_picker:
			temp_index = i
	current_value.state_hubs.erase(current_value.state_hubs[temp_index])
	emit_changed(get_edited_property(), current_value)

#Update current_value so the state_name matches what is selected in the inspector
func on_item_selected(index):
	var children = _state_picker_array_control.get_children()
	#brain_state
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(0)
		if i <= current_value.state_hubs.size():
			current_value.state_hubs[i-1].brain_state.state_name = drop_down.selected_option
		
	#direct_state
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(1)
		if i <= current_value.state_hubs.size():
			current_value.state_hubs[i-1].direct_state.state_name = drop_down.selected_option
	emit_changed(get_edited_property(), current_value)

#Connects appropriate state_hubs for the system to work
func refresh_drop_down_list():
	var children = _state_picker_array_control.get_children()
	children.remove_at(0)
	for i in range(0, children.size()):
		var brain_state_picker = children[i].get_child(0)
		if !brain_state_picker.is_connected("item_selected", Callable(self, "on_item_selected")):
			brain_state_picker.connect("item_selected", Callable(self, "on_item_selected"))
		
		var direct_state_picker = children[i].get_child(1)
		direct_state_picker.state_picker = current_value.state_hubs[i].direct_state
		if !direct_state_picker.is_connected("item_selected", Callable(self, "on_item_selected")):
			direct_state_picker.connect("item_selected", Callable(self, "on_item_selected"))
		if !direct_state_picker.is_connected("on_remove", Callable(self, "on_remove_element")):
			direct_state_picker.connect("on_remove", Callable(self, "on_remove_element"))

#Based on the signal_pickers in the property, regenerates the Control elements
func recreate_drop_down_list(prop):
	for i in range(0, prop.size()):
		_state_picker_array_control._add_element()
		
		#brain_state
		var drop_down = _state_picker_array_control.get_children()[i+1].get_child(0)
		for j in drop_down.item_count:
			if prop[i].brain_state.state_name == drop_down.get_item_text(j):
				#the select function doesn't emit the item_selected signal
				drop_down.select(j)
				drop_down.selected_option = drop_down.get_item_text(j)
		
		#direct_state
		drop_down = _state_picker_array_control.get_children()[i+1].get_child(1)
		for j in drop_down.item_count:
			if prop[i].direct_state.state_name == drop_down.get_item_text(j):
				#the select function doesn't emit the item_selected signal
				drop_down.select(j)
				drop_down.selected_option = drop_down.get_item_text(j)
