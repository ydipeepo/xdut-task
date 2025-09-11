class_name XDUT_UnwrapTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	depth: int,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"UnwrapTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if depth < 0:
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_UNWRAP_DEPTH"))
		return XDUT_CanceledTask.new(name)
	if depth == 0:
		return source_awaitable
	return new(source_awaitable, depth, cancel, name)

#-------------------------------------------------------------------------------

func _init(
	source_awaitable: Awaitable,
	depth: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_perform(source_awaitable, depth, cancel)

func _perform(source: Variant, depth: int, cancel: Cancel) -> void:
	var result: Variant = await source.wait(cancel)
	while result is Awaitable and depth != 0:
		source = result
		result = await source.wait(cancel)
		depth -= 1

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match source.get_state():
				STATE_COMPLETED:
					release_complete(result)
				STATE_CANCELED:
					release_cancel()
				_:
					assert(false, internal_get_task_canonical()
						.translate(&"ERROR_BAD_STATE")
						.format([source]))
