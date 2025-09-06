class_name XDUT_CompletedTask extends Task

#---------------------------------------------------------------------------------------------------
#	METHODS
#---------------------------------------------------------------------------------------------------

func get_state() -> int:
	return STATE_COMPLETED

func wait(cancel: Cancel = null) -> Variant:
	return _result

#---------------------------------------------------------------------------------------------------

var _name: StringName
var _result: Variant

func _init(result: Variant, name := &"CompletedTask") -> void:
	_name = name
	_result = result

func _to_string() -> String:
	var prefix: StringName = get_canonical() \
		.translate(&"TASK_STATE_COMPLETED")
	return &"%s<%s#%d>" % [prefix, _name, get_instance_id()]
