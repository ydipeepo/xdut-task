@tool
extends EditorPlugin

#-------------------------------------------------------------------------------

static func _add_setting(
	key: String,
	default_value: Variant,
	property_hint := PROPERTY_HINT_NONE,
	property_hint_string := "") -> void:

	if not ProjectSettings.has_setting(key):
		var property_info := {
			&"name": key,
			&"type": typeof(default_value),
			&"hint": property_hint,
			&"hint_string": property_hint_string,
		}

		ProjectSettings.set_setting(key, default_value)
		ProjectSettings.add_property_info(property_info)
		ProjectSettings.set_initial_value(key, default_value)
		ProjectSettings.set_as_basic(key, true)

func _get_plugin_name() -> String:
	return "Godot Task"

func _enable_plugin() -> void:
	var autoload_path := ResourceUID.ensure_path("uid://d4ixdr1hdia5t")
	add_autoload_singleton("_TaskAutoload", autoload_path)

func _disable_plugin() -> void:
	remove_autoload_singleton("_TaskAutoload")

func _enter_tree() -> void:
	_add_setting("godot_task/monitor/enable", true)
	_add_setting("godot_task/monitor/max_recursion", 3, PROPERTY_HINT_RANGE, "1,100")
	_add_setting("godot_task/monitor/force_finalize_when_addon_exit_tree", true)
	_add_setting("godot_task/debug/suppress_error_message", false)
	_add_setting("godot_task/debug/enable_strict_method_validation", false)
	_add_setting("godot_task/debug/enable_strict_signal_validation", false)

func _exit_tree() -> void:
	ProjectSettings.clear("godot_task/monitor/enable")
	ProjectSettings.clear("godot_task/monitor/max_recursion")
	ProjectSettings.clear("godot_task/monitor/force_finalize_when_addon_exit_tree")
	ProjectSettings.clear("godot_task/debug/suppress_error_message")
	ProjectSettings.clear("godot_task/debug/enable_strict_method_validation")
	ProjectSettings.clear("godot_task/debug/enable_strict_signal_validation")
