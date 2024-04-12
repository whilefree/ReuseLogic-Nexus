extends EditorProperty

# The main control for editing the property.
var _signal_picker_control = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_controls/signal_picker_drop_down.gd").new()
# An internal value of the property.
var current_value = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_classes/signal_picker_sibling.gd").new() as SignalPickerSibling
# A guard against internal changes when the property is updated.
var updating = false

func _init(obj = null, prop = null):
	var _brain = current_value.brain(obj.get_parent())
	if _brain:
		#Feed the signal_picker with Brain's signal names
		_signal_picker_control.init(_brain.get_signal_names())
	else:
		push_warning("Any Node using SignalPickerSibling must be the sibling of the Brain node for the SignalPickerSibling to work properly.")
	
	_signal_picker_control.connect("item_selected",Callable(self,"on_item_selected"))
	# Add the control as a direct child of EditorProperty node.
	add_child(_signal_picker_control)
	# Make sure the control is able to retain the focus.
	add_focusable(_signal_picker_control)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if new_value:
		new_value = new_value as SignalPickerSibling
		#Set the selected item: keeps the selected item inside the dropdown
		for i in _signal_picker_control.item_count:
			if new_value.signal_name == _signal_picker_control.get_item_text(i):
				_signal_picker_control.select(i)
				#So the item_selected signal is emitted:
				_signal_picker_control.selected_option = _signal_picker_control.get_item_text(i)
		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false

func on_item_selected(id):
	# Ignore the signal if the property is currently being updated.
	if updating:
		return
	current_value.signal_name = _signal_picker_control.get_item_text(id)
	emit_changed(get_edited_property(), current_value)
