@tool
extends EditorPlugin

var plugin

func _enter_tree():
	plugin = preload("res://addons/reuse_logic_nexus/inspector_plugin.gd").new()
	add_inspector_plugin(plugin)

func _exit_tree():
	remove_inspector_plugin(plugin)

func _enable_plugin():
	add_autoload_singleton("ReuseLogicNexus", "res://addons/reuse_logic_nexus/globals/reuse_logic_nexus_globals.gd")
