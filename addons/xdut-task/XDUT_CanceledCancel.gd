class_name XDUT_CanceledCancel extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_requested() -> bool:
	return true

func request() -> void:
	pass

#-------------------------------------------------------------------------------

func _to_string() -> String:
	var prefix: StringName = internal_task_get_canonical() \
		.translate(&"CANCEL_STATE_REQUESTED")
	return &"%s<CanceledCancel#%d>" % [prefix, get_instance_id()]
