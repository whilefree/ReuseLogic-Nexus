extends EditorProperty

# The main control for editing the property.
var _sender_signal_picker_array_control = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_controls/sender_signal_picker_array_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_classes/sender_signal_picker_array.gd").new() as SenderSignalPickerArray
var _brain:Brain
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	_brain = ReuseLogicNexus.get_brain_up(obj)
	if _brain:
		#Feed the signal_pickers with Brain's signal names
		_sender_signal_picker_array_control._array = _brain.get_signal_names()
	else:
		push_warning("Any Node using SenderSignalPickerArray must be a child of the Brain node for the SenderSignalPickerArray to work properly.")
	
	_sender_signal_picker_array_control.get_child(0).connect("pressed", Callable(self, "on_add_element"))
	
	if prop:
		current_value = prop
	
	recreate_drop_down_list(current_value.sender_signal_pickers)
	refresh_drop_down_list()
	# Add the control as a direct child of EditorProperty node.
	add_child(_sender_signal_picker_array_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_sender_signal_picker_array_control)

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
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the SenderSignalPickerArray
		push_warning("Any Node using SenderSignalPickerArray must be a child of the Brain node for the SenderSignalPickerArray to work properly.")
	if updating:
		return
	current_value.sender_signal_pickers.append(SenderSignalPicker.new())
	emit_changed(get_edited_property(), current_value)
	refresh_drop_down_list()

#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_element(item):
	var temp_index = 0
	for i in range(0, current_value.sender_signal_pickers.size()):
		if current_value.sender_signal_pickers[i] == item.sender_signal_picker:
			temp_index = i
	current_value.sender_signal_pickers.erase(current_value.sender_signal_pickers[temp_index])
	emit_changed(get_edited_property(), current_value)

#Update current_value so the sender_name matches what is selected in the inspector
func on_sender_item_selected(index):
	var children = _sender_signal_picker_array_control.get_children()
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(0).get_child(0)
		if i <= current_value.sender_signal_pickers.size():
			current_value.sender_signal_pickers[i-1].sender_name = drop_down.selected_option
	emit_changed(get_edited_property(), current_value)

#Update current_value so the signal_name matches what is selected in the inspector
func on_signal_item_selected(index):
	var children = _sender_signal_picker_array_control.get_children()
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(0).get_child(1)
		if i <= current_value.sender_signal_pickers.size():
			current_value.sender_signal_pickers[i-1].signal_name = drop_down.selected_option
	emit_changed(get_edited_property(), current_value)

#Connects appropriate signals for the system to work
func refresh_drop_down_list():
	var children = _sender_signal_picker_array_control.get_children()
	children.remove_at(0)
	for i in range(0, children.size()):
		var drop_down = children[i].get_child(0)
		drop_down.sender_signal_picker = current_value.sender_signal_pickers[i]
		if !drop_down.get_child(0).is_connected("item_selected", Callable(self, "on_sender_item_selected")):
			drop_down.get_child(0).connect("item_selected", Callable(self, "on_sender_item_selected"))
		if !drop_down.is_connected("on_remove", Callable(self, "on_remove_element")):
			drop_down.connect("on_remove", Callable(self, "on_remove_element"))
		if !drop_down.get_child(1).is_connected("item_selected", Callable(self, "on_signal_item_selected")):
			drop_down.get_child(1).connect("item_selected", Callable(self, "on_signal_item_selected"))

#Based on the signal_pickers in the property, regenerates the Control elements
func recreate_drop_down_list(prop):
	for i in range(0, prop.size()):
		_sender_signal_picker_array_control._add_element()
		var drop_down = _sender_signal_picker_array_control.get_children()[i+1].get_child(0)
		
		for j in drop_down.get_child(0).item_count:
			if prop[i].sender_name == drop_down.get_child(0).get_item_text(j):
				#the select function doesn't emit the item_selected signal
				drop_down.get_child(0).select(j)
				drop_down.get_child(0).selected_option = drop_down.get_child(0).get_item_text(j)
		
		for j in drop_down.get_child(1).item_count:
			if prop[i].signal_name == drop_down.get_child(1).get_item_text(j):
				#the select function doesn't emit the item_selected signal
				drop_down.get_child(1).select(j)
				drop_down.get_child(1).selected_option = drop_down.get_child(1).get_item_text(j)
