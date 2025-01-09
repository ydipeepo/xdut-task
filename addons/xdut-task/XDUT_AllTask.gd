class_name XDUT_AllTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_inits: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"AllTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if from_inits.is_empty():
		return XDUT_CompletedTask.new([], name)
	return new(
		from_inits,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _remaining: int

func _init(
	from_inits: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	var from_inits_size := from_inits.size()
	var result_set := []; result_set.resize(from_inits_size)
	_remaining = from_inits_size
	for task_index: int in from_inits_size:
		var task := XDUT_FromTask.create(
			from_inits[task_index],
			cancel,
			true)
		_perform(
			task,
			task_index,
			cancel,
			result_set)

func _perform(
	task: Awaitable,
	task_index: int,
	cancel: Cancel,
	result_set: Array) -> void:

	var result: Variant = await task.wait(cancel)
	if is_pending:
		match task.get_state():
			STATE_COMPLETED:
				result_set[task_index] = result
				_remaining -= 1
				if _remaining == 0:
					release_complete(result_set)
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state_at(task, task_index)
