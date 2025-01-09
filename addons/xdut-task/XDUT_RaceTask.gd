class_name XDUT_RaceTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_inits: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"RaceTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if from_inits.is_empty():
		push_warning("Invalid inputs.")
		return XDUT_NeverTask.create(
			cancel,
			true,
			name)

	return new(
		from_inits,
		cancel,
		name)

#-------------------------------------------------------------------------------

func _init(
	from_inits: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	for task_index: int in from_inits.size():
		var task := XDUT_FromTask.create(
			from_inits[task_index],
			cancel,
			true)
		_perform(
			task,
			task_index,
			cancel)

func _perform(
	task: Awaitable,
	task_index: int,
	cancel: Cancel) -> void:

	var result: Variant = await task.wait(cancel)
	if is_pending:
		match task.get_state():
			STATE_COMPLETED:
				release_complete(XDUT_CompletedTask.new(result))
			STATE_CANCELED:
				release_complete(XDUT_CanceledTask.new())
			_:
				error_bad_state_at(task, task_index)
