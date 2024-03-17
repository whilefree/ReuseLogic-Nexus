extends EditorProperty

# The main control for editing the property.
var _sender_signal_picker_control = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_controls/sender_signal_picker_control.tscn").instantiate()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_classes/sender_signal_picker.gd").new()
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	#Feed the sender_picker with Brain's signal names
	_sender_signal_picker_control.get_child(0).init(ReuseLogicNexus.get_sender_list())
	var _brain = current_value.brain(obj)
	if _brain:
		#Feed the signal_picker with Brain's signal names
		_sender_signal_picker_control.get_child(1).init(_brain.get_signal_names())
	else: #I should see how I can pass a warning notification to the node itself...
		push_warning("Any Node using SenderSignalPicker must be a child of the Brain node for the SenderSignalPicker to work properly.")
	_sender_signal_picker_control.get_child(1).connect("item_selected",on_signal_item_selected)
	_sender_signal_picker_control.get_child(0).connect("item_selected",on_sender_item_selected)
	# Add the control as a direct child of EditorProperty node.
	add_child(_sender_signal_picker_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_sender_signal_picker_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as SenderSignalPicker
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _sender_signal_picker_control.get_child(1).item_count:
			if new_value.signal_name == _sender_signal_picker_control.get_child(1).get_item_text(i):
				_sender_signal_picker_control.get_child(1).select(i)
				#So the item_selected signal is emitted:
				_sender_signal_picker_control.get_child(1).selected_option = _sender_signal_picker_control.get_child(1).get_item_text(i)
			
		for i in _sender_signal_picker_control.get_child(0).item_count:
			if new_value.sender_name == _sender_signal_picker_control.get_child(0).get_item_text(i):
				_sender_signal_picker_control.get_child(0).select(i)
				#So the item_selected signal is emitted:
				_sender_signal_picker_control.get_child(0).selected_option = _sender_signal_picker_control.get_child(0).get_item_text(i)
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_signal_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.signal_name = _sender_signal_picker_control.get_child(1).get_item_text(id)
	emit_changed(get_edited_property(), current_value)

func on_sender_item_selected(id):
	current_value.sender_name = _sender_signal_picker_control.get_child(0).get_item_text(id)
	emit_changed(get_edited_property(), current_value)
