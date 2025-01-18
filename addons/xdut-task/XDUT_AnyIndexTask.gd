class_name XDUT_AnyIndexTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_inits: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"AnyIndexTask") -> Task:

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
	if _cancel_pendings != null:
		_cancel_pendings.request()
		_cancel_pendings = null
	super()

#-------------------------------------------------------------------------------

var _cancel_pendings := Cancel.create()
var _remaining: int

func _init(
	from_inits: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	var from_inits_size := from_inits.size()
	_remaining = from_inits_size
	for task_index: int in from_inits_size:
		var task := XDUT_FromTask.create(
			from_inits[task_index],
			cancel,
			true)
		_perform(
			task,
			task_index)

func _perform(
	task: Variant,
	task_index: int) -> void:

	await task.wait(_cancel_pendings)
	if is_pending:
		match task.get_state():
			STATE_COMPLETED:
				release_complete(task_index)
			STATE_CANCELED:
				_remaining -= 1
				if _remaining == 0:
					release_cancel()
			_:
				error_bad_state_at(task, task_index)
