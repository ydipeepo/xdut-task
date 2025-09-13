class_name XDUT_DelayTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DelayTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if timeout < _MIN_TIMEOUT:
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_TIMEOUT"))
		return XDUT_CompletedTask.new(null, name)
	if timeout == _MIN_TIMEOUT:
		return XDUT_CompletedTask.new(null, name)
	return new(
		timeout,
		ignore_pause,
		ignore_time_scale,
		cancel,
		name)

func cleanup() -> void:
	if _timer != null:
		if _timer.timeout.is_connected(_on_timeout):
			_timer.timeout.disconnect(_on_timeout)
		_timer = null
	super()

#-------------------------------------------------------------------------------

const _MIN_TIMEOUT := 0.0

var _timer: SceneTreeTimer

func _init(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_timer = internal_get_task_canonical() \
		.create_timer(
			timeout,
			ignore_pause,
			ignore_time_scale)
	_timer.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	release_complete()
