extends EditorInspectorPlugin

var _signal_picker = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_editor_property.gd")
var _signal_picker_child = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_child_editor_property.gd")
var _signal_picker_sibling = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_sibling_editor_property.gd")
var _signal_picker_array = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_array_editor_property.gd")
var _signal_picker_group = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_group_editor_property.gd")
var _signal_picker_group_array = preload("res://addons/reuse_logic_nexus/modules/signal_picker/signal_picker_editor_properties/signal_picker_group_array_editor_property.gd")

var _action_emitter = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_editor_properties/action_emitter_editor_property.gd")
var _action_emitter_array = preload("res://addons/reuse_logic_nexus/modules/action_emitter/action_emitter_editor_properties/action_emitter_array_editor_property.gd")

var _direct_state_picker = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_editor_properties/direct_state_picker_editor_property.gd")
var _brain_state_picker = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_editor_properties/brain_state_picker_editor_property.gd")
var _state_hub_picker = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_editor_properties/state_hub_editor_property.gd")
var _state_hub_array = preload("res://addons/reuse_logic_nexus/modules/brain_system/state_picker/state_picker_editor_properties/state_hub_array_editor_property.gd")

var _sender_picker = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_editor_properties/sender_picker_editor_property.gd")
var _sender_signal_picker = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_editor_properties/sender_signal_picker_editor_property.gd")
var _sender_signal_picker_array = preload("res://addons/reuse_logic_nexus/modules/sender_system/sender_picker/sender_picker_editor_properties/sender_signal_picker_array_editor_property.gd")

var _global_signal_picker = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_editor_properties/global_signal_picker_editor_property.gd")
var _global_local_signal_pair = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_editor_properties/global_local_signal_pair_editor_property.gd")
var _global_local_signal_pair_array = preload("res://addons/reuse_logic_nexus/modules/global_signal_system/global_signal_picker/global_signal_picker_editor_properties/global_local_signal_pair_array_editor_property.gd")

func _can_handle(object):
	# All objects are supported by the system
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#Make sure it's not int, sprite, etc...
	#And make sure object exists:
	if type == TYPE_OBJECT && object:
		if hint_string == "SignalPicker":
			#It's SignalPicker.
			add_property_editor(name, _signal_picker.new(object, object[name]))
			return true
		if hint_string == "SignalPickerChild":
			#It's SignalPickerChild.
			add_property_editor(name, _signal_picker_child.new(object, object[name]))
			return true
		if hint_string == "SignalPickerSibling":
			#It's SignalPickerSibling.
			add_property_editor(name, _signal_picker_sibling.new(object, object[name]))
			return true
		if hint_string == "SignalPickerArray":
			#It's SignalPickerArray.
			add_property_editor(name, _signal_picker_array.new(object, object[name]))
			return true
		if hint_string == "SignalPickerGroup":
			#It's SignalPickerGroup.
			add_property_editor(name, _signal_picker_group.new(object, object[name]))
			return true
			
		if hint_string == "SignalPickerGroupArray":
			#It's SignalPickerGroup.
			add_property_editor(name, _signal_picker_group_array.new(object, object[name]))
			return true
			
		if hint_string == "ActionEmitter":
			#It's ActionEmitter.
			add_property_editor(name, _action_emitter.new(object, object[name]))
			return true
			
		if hint_string == "ActionEmitterArray":
			#It's ActionEmitterArray.
			add_property_editor(name, _action_emitter_array.new(object, object[name]))
			return true
			
		if hint_string == "DirectStatePicker":
			#It's DirectStatePicker.
			add_property_editor(name, _direct_state_picker.new(object, object[name]))
			return true
		
		if hint_string == "BrainStatePicker":
			#It's BrainStatePicker.
			add_property_editor(name, _brain_state_picker.new(object, object[name]))
			return true
			
		if hint_string == "StateHub":
			#It's StateHub.
			add_property_editor(name, _state_hub_picker.new(object, object[name]))
			return true
		
		if hint_string == "StateHubArray":
			#It's StateHub.
			add_property_editor(name, _state_hub_array.new(object, object[name]))
			return true
			
		if hint_string == "SenderPicker":
			#It's SenderPicker.
			add_property_editor(name, _sender_picker.new(object, object[name]))
			return true
		
		if hint_string == "SenderSignalPicker":
			#It's SenderSignalPicker.
			add_property_editor(name, _sender_signal_picker.new(object, object[name]))
			return true
		
		if hint_string == "SenderSignalPickerArray":
			#It's SenderSignalPickerArray.
			add_property_editor(name, _sender_signal_picker_array.new(object, object[name]))
			return true
		
		if hint_string == "GlobalSignalPicker":
			#It's GlobalSignalPicker.
			add_property_editor(name, _global_signal_picker.new(object, object[name]))
			return true
		
		if hint_string == "GlobalLocalSignalPair":
			#It's GlobalLocalSignalPair.
			add_property_editor(name, _global_local_signal_pair.new(object, object[name]))
			return true
		
		if hint_string == "GlobalLocalSignalPairArray":
			#It's GlobalLocalSignalPairArray.
			add_property_editor(name, _global_local_signal_pair_array.new(object, object[name]))
			return true

#Used for debugging...
func report(object, type, name, hint_type, hint_string):
		print(object) #name of the object having the property
		print(name)
		print(object[name])
		print(hint_type)
		print(hint_string)
		print("************************")
