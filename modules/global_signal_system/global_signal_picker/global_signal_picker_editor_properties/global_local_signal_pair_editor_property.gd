extends EditorProperty

# The main control for editing the property.
var _global_local_signal_pair_control = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_controls/global_local_signal_pair_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_classes/global_local_signal_pair.gd").new() as GlobalLocalSignalPair
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	#Feed the global signal_picker with the global signals
	_global_local_signal_pair_control.get_child(0).init(ReuseLogicNexus.get_signal_list())
	var _brain = current_value.local_signal.brain(obj)
	if _brain:
		#Feed the local signal_picker with Brain's signal names
		_global_local_signal_pair_control.get_child(1).init(_brain.get_signal_names())
	else:
		push_warning("Any Node using GlobalLocalSignalPair must be a child of the Brain node for the GlobalLocalSignalPair to work properly.")
	_global_local_signal_pair_control.get_child(1).connect("item_selected",on_signal_item_selected)
	_global_local_signal_pair_control.get_child(0).connect("item_selected",on_global_signal_item_selected)
	# Add the control as a direct child of EditorProperty node.
	add_child(_global_local_signal_pair_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_global_local_signal_pair_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as GlobalLocalSignalPair
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _global_local_signal_pair_control.get_child(1).item_count:
			if new_value.local_signal.signal_name == _global_local_signal_pair_control.get_child(1).get_item_text(i):
				_global_local_signal_pair_control.get_child(1).select(i)
				#So the item_selected signal is emitted:
				_global_local_signal_pair_control.get_child(1).selected_option = _global_local_signal_pair_control.get_child(1).get_item_text(i)
			
		for i in _global_local_signal_pair_control.get_child(0).item_count:
			if new_value.global_signal.signal_name == _global_local_signal_pair_control.get_child(0).get_item_text(i):
				_global_local_signal_pair_control.get_child(0).select(i)
				#So the item_selected signal is emitted:
				_global_local_signal_pair_control.get_child(0).selected_option = _global_local_signal_pair_control.get_child(0).get_item_text(i)
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_signal_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.local_signal.signal_name = _global_local_signal_pair_control.get_child(1).get_item_text(id)
	emit_changed(get_edited_property(), current_value)

func on_global_signal_item_selected(id):
	current_value.global_signal.signal_name = _global_local_signal_pair_control.get_child(0).get_item_text(id)
	emit_changed(get_edited_property(), current_value)
