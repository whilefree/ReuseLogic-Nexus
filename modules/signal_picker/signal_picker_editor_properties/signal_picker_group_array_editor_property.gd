extends EditorProperty

# The main control for editing the property.
var _signal_picker_control = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_controls/signal_picker_group_array_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_classes/signal_picker_group_array.gd").new() as SignalPickerGroupArray
var _brain:Brain
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	_brain = ReuseLogicNexus.get_brain_up(obj)
	if _brain:
		#Feed the signal_pickers with Brain's signal names
		_signal_picker_control._array = _brain.get_signal_names()
	else:
		push_warning("Any Node using SignalPickerGroupArray must be a child of the Brain node for the SignalPickerGroupArray to work properly.")
	
	if prop:
		current_value = prop
	
	#Connect "Add Signal Group" button press signal
	_signal_picker_control.get_child(0).connect("pressed", Callable(self, "on_add_signal_group"))
	
	recreate_group_drop_down_list(current_value.signal_groups)
	refresh_group_drop_down_list()
	
	# Add the control as a direct child of EditorProperty node.
	add_child(_signal_picker_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_signal_picker_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	if new_value:
		current_value = new_value
	updating = false

#Synchronizes the group elements and the internal property upon the creation of an element
func on_add_signal_group():
	#print("signal group added")
	if !_brain:
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the SignalPickerGroupArray
		push_warning("Any Node using SignalPickerGroupArray must be a child of the Brain node for the SignalPickerGroupArray to work properly.")
	if updating:
		return
	current_value.signal_groups.append(SignalPickerGroup.new())
	current_value.signal_groups[current_value.signal_groups.size() - 1].signal_to_listen = SignalPicker.new()
	refresh_group_drop_down_list()
	emit_changed(get_edited_property(), current_value)

#Synchronizes the elements and the internal property upon the creation of an element
func on_add_element(group, array):
	#print("element added")
	if !_brain:
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the SignalPickerGroupArray
		push_warning("Any Node using SignalPickerGroupArray must be a child of the Brain node for the SignalPickerGroupArray to work properly.")
	if updating:
		return
	
	var children = _signal_picker_control.get_children()
	children.remove_at(0)
	
	for i in range(0,children.size()):
		if children[i].get_child(0) == group:
			var sp = SignalPicker.new()
			current_value.signal_groups[i].signals_to_raise.append(sp)
			var array_children = array.get_children()
			array_children.remove_at(0)
			for j in range(0 , array_children.size()):
				var drop_down = array_children[j].get_child(0)
				drop_down.signal_picker = current_value.signal_groups[i].signals_to_raise[j]
	
	refresh_group_drop_down_list()
	emit_changed(get_edited_property(), current_value)
	
func on_item_selected(group,array,item):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
		
	var groups = _signal_picker_control.get_children()
	groups.remove_at(0) #removes Add Signal Button
	
	for i in range(0, groups.size()):
		if groups[i].get_child(0) == group:
			for j in range(0, current_value.signal_groups[i].signals_to_raise.size()):
				if current_value.signal_groups[i].signals_to_raise[j] == item.signal_picker:
					current_value.signal_groups[i].signals_to_raise[j].signal_name = item.selected_option
	emit_changed(get_edited_property(), current_value)

#Update current_value so the signal_name matches what is selected in the inspector
func on_signal_to_listen_item_selected(item):
	var groups = _signal_picker_control.get_children()
	groups.remove_at(0) #removes Add Signal Button
	for i in range(0, groups.size()):
		var signal_to_listen = groups[i].get_child(0).get_child(0)
		if !current_value.signal_groups[i].signal_to_listen:
			current_value.signal_groups[i].signal_to_listen = SignalPicker.new()
		current_value.signal_groups[i].signal_to_listen.signal_name = signal_to_listen.selected_option
	emit_changed(get_edited_property(), current_value)

#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_element(group, array, item):
	var groups = _signal_picker_control.get_children()
	groups.remove_at(0) #removes Add Signal Button
	var temp_i = 0
	var temp_j = 0
	for i in range(0, groups.size()):
		if groups[i].get_child(0) == group:
			for j in range(0, current_value.signal_groups[i].signals_to_raise.size()):
				if current_value.signal_groups[i].signals_to_raise[j] == item.signal_picker:
					temp_i = i
					temp_j = j
	current_value.signal_groups[temp_i].signals_to_raise.erase(current_value.signal_groups[temp_i].signals_to_raise[temp_j])
	emit_changed(get_edited_property(), current_value)
	
#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_group_element(item):
	var temp_index = 0
	for i in range(0, current_value.signal_groups.size()):
		if current_value.signal_groups[i] == item:
			temp_index = i
	current_value.signal_groups.erase(current_value.signal_groups[temp_index])
	emit_changed(get_edited_property(), current_value)

#Connects appropriate signals for the system to work
func refresh_group_drop_down_list():
	var children = _signal_picker_control.get_children()
	children.remove_at(0) #Remove Add Signal Group Button
	for i in range(0, children.size()):
		var signal_picker_group_control = children[i].get_child(0)
		var remove_group_button = children[i].get_child(1)
		var signal_to_listen = signal_picker_group_control.get_child(0)
		var signal_picker_array = signal_picker_group_control.get_child(1)
		var add_element_button = signal_picker_array.get_child(0)

		signal_picker_group_control.signal_picker_group = current_value.signal_groups[i]
		select_item_by_name(signal_to_listen,current_value.signal_groups[i].signal_to_listen.signal_name)

		if !signal_to_listen.is_connected("on_item_selected", Callable(self, "on_signal_to_listen_item_selected")):
			signal_to_listen.connect("on_item_selected", Callable(self, "on_signal_to_listen_item_selected"))
		if !signal_picker_group_control.is_connected("on_remove", Callable(self, "on_remove_group_element")):
			signal_picker_group_control.connect("on_remove", Callable(self, "on_remove_group_element"))
		if !_signal_picker_control.is_connected("on_child_item_added", Callable(self, "on_add_element")):
			_signal_picker_control.connect("on_child_item_added", Callable(self, "on_add_element"))
		if !_signal_picker_control.is_connected("on_child_item_removed", Callable(self, "on_remove_element")):
			_signal_picker_control.connect("on_child_item_removed", Callable(self, "on_remove_element"))
		if !_signal_picker_control.is_connected("on_child_item_selected", Callable(self, "on_item_selected")):
				_signal_picker_control.connect("on_child_item_selected", Callable(self, "on_item_selected"))

#Based on the signal_groups in the property, regenerates the Control elements
func recreate_group_drop_down_list(prop_groups):
	for i in range(0, prop_groups.size()):
		#Make groups...
		_signal_picker_control._add_element()
	
	var groups = _signal_picker_control.get_children()
	groups.remove_at(0) #removes Add Signal Button
	
	for i in range(0, groups.size()):
		var sp_group_control = groups[i].get_child(0)
		sp_group_control.signal_picker_group = current_value.signal_groups[i]
		var sp_array_control = sp_group_control.get_child(1)
		for j in range(0, current_value.signal_groups[i].signals_to_raise.size()):
			sp_array_control._add_element()
	
		var items = sp_array_control.get_children()
		items.remove_at(0)
		for j in range(0, items.size()):
			var drop_down = items[j].get_child(0)
			drop_down.signal_picker = current_value.signal_groups[i].signals_to_raise[j]
			select_item_by_name(drop_down,current_value.signal_groups[i].signals_to_raise[j].signal_name)

func select_item_by_name(items, name:String):
	for i in items.item_count:
		if name == items.get_item_text(i):
			items.select(i)
			#the select function above doesn't emit the item_selected signal. So:
			items.selected_option = items.get_item_text(i)
