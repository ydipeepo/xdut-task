class_name XDUT_UnwrapTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent: Awaitable,
	depth: int,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"UnwrapTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(antecedent) or antecedent.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if depth < 0:
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_UNWRAP_DEPTH"))
		return XDUT_CanceledTask.new(name)
	if depth == 0:
		return antecedent
	return new(antecedent, depth, cancel, name)

#-------------------------------------------------------------------------------

func _init(
	antecedent: Awaitable,
	depth: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_perform(antecedent, depth, cancel)

func _perform(antecedent: Variant, depth: int, cancel: Cancel) -> void:
	var result: Variant = await antecedent.wait(cancel)
	while result is Awaitable and depth != 0:
		antecedent = result
		result = await antecedent.wait(cancel)
		depth -= 1

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match antecedent.get_state():
				STATE_COMPLETED:
					release_complete(result)
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT")
						.format([antecedent]))
					breakpoint
