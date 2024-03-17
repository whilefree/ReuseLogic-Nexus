extends EditorProperty

# The main control for editing the property.
var _signal_picker_control = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_controls/signal_picker_group_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_classes/signal_picker_group.gd").new() as SignalPickerGroup
var _brain:Brain
# A guard against internal changes when the property is updated.
var updating = false

#signal_to_listen control
var drop_down
#signal_to_raise control
var signal_array

func _init(obj = null, prop = null):
	drop_down = _signal_picker_control.get_child(0)
	signal_array = _signal_picker_control.get_child(1)
	_brain = ReuseLogicNexus.get_brain_up(obj)
	if _brain:
		#Feed the signal_pickers with Brain's signal names
		drop_down.init(_brain.get_signal_names())
		signal_array._array = _brain.get_signal_names()
	else:
		push_warning("Any Node using SignalPickerGroup must be a child of the Brain node for the SignalPickerGroup to work properly.")
	
	if prop:
		current_value = prop
	
	#Connect Add Element button press signal
	signal_array.get_child(0).connect("pressed", Callable(self, "on_add_element"))
	#Connect the selection signal of the signal_to_listen control
	drop_down.connect("item_selected",Callable(self,"on_item_selected"))
	
	#Make the drop_down selected item match with the property
	if current_value.signal_to_listen:
		for i in drop_down.item_count:
			if current_value.signal_to_listen.signal_name == drop_down.get_item_text(i):
				drop_down.select(i)
	
	recreate_drop_down_list(current_value.signals_to_raise)
	refresh_drop_down_list()
	
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

#Synchronizes the elements and the internal property upon the creation of an element
func on_add_element():
	if !_brain:
		#Show the warning just in case the designer didn't notice there isn't a Brain parented to the node using the SignalPickerGroup
		push_warning("Any Node using SignalPickerGroup must be a child of the Brain node for the SignalPickerGroup to work properly.")
	if updating:
		return
	
	current_value.signals_to_raise.append(SignalPicker.new())
	refresh_drop_down_list()
	emit_changed(get_edited_property(), current_value)

func on_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	#Create the SignalPicker if it's the first time it's being used
	if !current_value.signal_to_listen:
		current_value.signal_to_listen = SignalPicker.new()
	current_value.signal_to_listen.signal_name = drop_down.get_item_text(id)
	emit_changed(get_edited_property(), current_value)

#Synchronizes the elements and the internal property upon deletion of an element
func on_remove_element(item):
	var temp_index = 0
	for i in range(0, current_value.signals_to_raise.size()):
		if current_value.signals_to_raise[i] == item.signal_picker:
			temp_index = i
	current_value.signals_to_raise.erase(current_value.signals_to_raise[temp_index])
	emit_changed(get_edited_property(), current_value)

#Update current_value so the signal_name matches what is selected in the inspector
func on_item_selected_in_array(index):
	var children = signal_array.get_children()
	for i in range(1, children.size()):
		var drop_down = children[i].get_child(0)
		if i <= current_value.signals_to_raise.size():
			current_value.signals_to_raise[i-1].signal_name = drop_down.selected_option
	emit_changed(get_edited_property(), current_value)

#Connects appropriate signals for the system to work
func refresh_drop_down_list():
	var children = signal_array.get_children()
	for i in range(1, children.size()):
		if i:
			var drop_down = children[i].get_child(0)
			drop_down.signal_picker = current_value.signals_to_raise[i-1]
			if !drop_down.is_connected("item_selected", Callable(self, "on_item_selected_in_array")):
				drop_down.connect("item_selected", Callable(self, "on_item_selected_in_array"))
			if !drop_down.is_connected("on_remove", Callable(self, "on_remove_element")):
				drop_down.connect("on_remove", Callable(self, "on_remove_element"))

#Based on the signals in the property, regenerates the Control elements
func recreate_drop_down_list(prop):
	for i in range(0, prop.size()):
		signal_array._add_element()
		var drop_down = signal_array.get_children()[i+1].get_child(0)
		
		for j in drop_down.item_count:
			if prop[i].signal_name == drop_down.get_item_text(j):
				#the select function doesn't emit the item_selected signal
				drop_down.select(j)
				drop_down.selected_option = drop_down.get_item_text(j)
