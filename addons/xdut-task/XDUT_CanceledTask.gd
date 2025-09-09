class_name XDUT_CanceledTask extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_state() -> int:
	return STATE_CANCELED

func wait(cancel: Cancel = null) -> Variant:
	return null

#-------------------------------------------------------------------------------

var _name: StringName

func _init(name := &"CanceledTask") -> void:
	_name = name

func _to_string() -> String:
	var prefix: StringName = internal_task_get_canonical() \
		.translate(&"TASK_STATE_CANCELED")
	return &"%s<%s#%d>" % [prefix, _name, get_instance_id()]
