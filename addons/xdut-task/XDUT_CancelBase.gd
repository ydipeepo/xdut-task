class_name XDUT_CancelBase extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_requested() -> bool:
	return _requested

func request() -> void:
	if not _requested:
		_requested = true
		requested.emit()

#-------------------------------------------------------------------------------

var _name: StringName
var _requested := false

func _init(name: StringName) -> void:
	_name = name

func _to_string() -> String:
	var prefix: StringName = internal_task_get_canonical() \
		.translate(
			&"CANCEL_STATE_REQUESTED"
			if get_requested() else
			&"CANCEL_STATE_PENDING")
	return &"%s<%s#%d>" % [prefix, _name, get_instance_id()]
