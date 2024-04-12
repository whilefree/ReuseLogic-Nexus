@icon("res://addons/reuse_logic_nexus/icons/Sender.png")
@tool
class_name Sender
extends Node

var _brain:Brain

##The Sender will be activated if this signal is emitted. Pass "sender_target" as the data or the Sender won't work properly.
@export var send_signal:SignalPicker
##The signal to be emitted if the Receiver informs the Sender of Successful Reception.
@export var received_signal:SignalPicker
##The Sender Type. The type selected here must match the type selected in the target Receiver, or nothing will happen.
@export var sender_type:SenderPicker

func _ready():
	if !Engine.is_editor_hint():
		_brain = ReuseLogicNexus.get_brain_up(self)
		_brain.register_signal(send_signal, send)

func send(data):
	if !data.has("sender_target"):
		push_error("The Sender Module needs a 'sender_target' to work properly. Pass it in the data dicitonary when emitting the 'send_signal'")
		return
	var brain = ReuseLogicNexus.get_brain_down(data["sender_target"])
	if brain:
		var children = brain.find_children("","Receiver")
		if children:
			var receiver = children[0] as Receiver
			#just in case the send is happening sooner than ready funciton of the receiver
			receiver._brain = brain
			for item in receiver.sender_list.sender_signal_pickers:
				if item.sender_name == sender_type.sender_name:
					#erasing the unnecessary information:
					var new_data = {}
					new_data["sender_type"] = sender_type.sender_name
					new_data["sender_owner"] = owner
					new_data["sender"] = self
					children[0].receive(new_data)

#Called by the Receiver to inform the Sender of Successful Reception.
func received(data):
	_brain.emit_signal(received_signal.signal_name, data)

func _get_configuration_warnings():
	var warnings = []
	if !ReuseLogicNexus.get_brain_up(self) is Brain:
		warnings.append("The Sender Module must be a direct/indirect child of the Brain node to work properly.")
	return warnings
