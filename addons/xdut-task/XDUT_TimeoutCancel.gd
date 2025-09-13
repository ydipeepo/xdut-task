class_name XDUT_TimeoutCancel extends XDUT_CancelBase

#-------------------------------------------------------------------------------

var _timer: SceneTreeTimer

func _init(timeout: float, ignore_pause: bool, ignore_time_scale: bool) -> void:
	super(&"TimeoutCancel")
	_timer = internal_get_task_canonical() \
		.create_timer(
			timeout,
			ignore_pause,
			ignore_time_scale)
	_timer.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	if _timer != null:
		_timer.timeout.disconnect(_on_timeout)
		_timer = null
	request()
