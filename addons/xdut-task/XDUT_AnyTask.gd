class_name XDUT_AnyTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_inits: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"AnyTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if from_inits.is_empty():
		return XDUT_CanceledTask.new(name)

	return new(
		from_inits,
		cancel,
		name)

func cleanup() -> void:
	for task_index: int in _awaitable_set.size():
		var task: Task = _awaitable_set[task_index]
		_awaitable_set[task_index] = null
		if task is TaskBase:
			task.release(self)
	super()

#-------------------------------------------------------------------------------

var _awaitable_set: Array[Awaitable]
var _remaining: int

func _init(
	from_inits: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	var from_inits_size := from_inits.size()
	_remaining = from_inits_size
	_awaitable_set.resize(from_inits_size)
	for task_index: int in from_inits_size:
		_awaitable_set[task_index] = XDUT_FromTask.create(
			from_inits[task_index],
			cancel,
			true)
	for task_index: int in from_inits_size:
		var task: Task = _awaitable_set[task_index]
		_perform(
			task,
			task_index,
			cancel)

func _perform(
	task: Task,
	task_index: int,
	cancel: Cancel) -> void:

	var result: Variant
	if task is TaskBase:
		result = await task.wait_temporary(self, cancel)
	elif task is Awaitable:
		result = await task.wait(cancel)

	if is_pending:
		match task.get_state():
			STATE_COMPLETED:
				release_complete(result)
			STATE_CANCELED:
				_remaining -= 1
				if _remaining == 0:
					release_cancel()
			_:
				error_bad_state_at(task, task_index)
