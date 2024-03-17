extends EditorProperty

# The main control for editing the property.
var _action_emitter_array_control = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_controls/action_emitter_array_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_classes/action_emitter_array.gd").new() as ActionEmitterArray
var _brain:Brain
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	_brain = SignalPicker.new().brain(obj)
	if _brain:
		#Feed the signal_pickers with Brain's signal names
		_action_emitter_array_control._array = _brain.get_signal_names()
	else:
		push_warning("Any Node using ActionEmitterArray must be a child of the Brain node for the ActionEmitterArray to work properly.")
	
	_action_emitter_array_control.get_child(0).connect("pressed", Callable(self, "on_add_element"))
	
	if prop:
		current_value = prop

	recreate_drop_down_list(current_value.action_emitters)
	refresh_drop_down_list()
	# Add the control as a direct child of EditorProperty node.
	add_child(_action_emitter_array_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_action_emitter_array_control)

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
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the ActionEmitterArray
		push_warning("Any Node using ActionEmitterArray must be a child of the Brain node for the ActionEmitterArray to work properly.")
	if updating:
		return
	current_value.action_emitters.append(ActionEmitter.new())
	refresh_drop_down_list()
	emit_changed(get_edited_property(), current_value)

#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_element(item):
	var temp_index = 0
	for i in range(0, current_value.action_emitters.size()):
		if current_value.action_emitters[i] == item.action_emitter:
			temp_index = i
	current_value.action_emitters.erase(current_value.action_emitters[temp_index])
	emit_changed(get_edited_property(), current_value)

#Update current_value so the signal_name matches what is selected in the inspector
func on_item_selected(index):
	var children = _action_emitter_array_control.get_children()
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(0).get_child(1)
		if i <= current_value.action_emitters.size():
			current_value.action_emitters[i-1].signal_name = drop_down.selected_option
	emit_changed(get_edited_property(), current_value)

#Happens when the text is changed inside the ActionEmitter
func on_text_changed(item, text):
	var children = _action_emitter_array_control.get_children()
	children.remove_at(0)
	for i in range(0,children.size()):
		var line_edit = children[i].get_child(0).get_child(0)
		if item.get_child(0) == line_edit:
			current_value.action_emitters[i].action_name = text
	emit_changed(get_edited_property(), current_value)

#Connects appropriate signals for the system to work
func refresh_drop_down_list():
	var children = _action_emitter_array_control.get_children()
	children.remove_at(0)
	for i in range(0, children.size()):
		var drop_down = children[i].get_child(0).get_child(1)
		
		#So we can check in the remove function if the action emitter in the inspector matches the one in the current_value, if so we remove it...
		children[i].get_child(0).action_emitter = current_value.action_emitters[i]
		
		if !drop_down.is_connected("item_selected", Callable(self, "on_item_selected")):
			drop_down.connect("item_selected", Callable(self, "on_item_selected"))
		if !children[i].get_child(0).is_connected("on_child_text_changed", Callable(self, "on_text_changed")):
			children[i].get_child(0).connect("on_child_text_changed", Callable(self, "on_text_changed"))
		if !children[i].get_child(0).is_connected("on_remove", Callable(self, "on_remove_element")):
			children[i].get_child(0).connect("on_remove", Callable(self, "on_remove_element"))

#Based on the data in the property, regenerates the Control elements
func recreate_drop_down_list(prop):
	for i in range(0, prop.size()):
		_action_emitter_array_control._add_element()
		var drop_down = _action_emitter_array_control.get_children()[i+1].get_child(0).get_child(1)
		var line_edit = _action_emitter_array_control.get_children()[i+1].get_child(0).get_child(0)
		line_edit.text = prop[i].action_name
		for j in drop_down.item_count:
			if prop[i].signal_name == drop_down.get_item_text(j):
				drop_down.select(j)
				#the select function above doesn't emit the item_selected signal. So:
				drop_down.selected_option = drop_down.get_item_text(j)
