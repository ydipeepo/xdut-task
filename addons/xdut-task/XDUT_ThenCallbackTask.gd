class_name XDUT_ThenCallbackTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent: Awaitable,
	method: Callable,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenCallbackTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(antecedent) or antecedent.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if not method.is_valid():
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD"))
		return XDUT_CanceledTask.new(name)
	if not method.get_argument_count() in _VALID_METHOD_ARGC:
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_METHOD_ARGC")
			.format([method.get_method(), method.get_argument_count()]))
		return XDUT_CanceledTask.new(name)
	return new(antecedent, method, cancel, name)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

const _VALID_METHOD_ARGC: Array[int] = [2, 3, 4]

var _method: Callable

func _init(
	antecedent: Awaitable,
	method: Callable,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_method = method
	_perform(antecedent, cancel)

func _perform(antecedent: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await antecedent.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match antecedent.get_state():
				STATE_COMPLETED:
					if _method.is_valid():
						match _method.get_argument_count():
							2: await _method.call(result, _set_core)
							3: await _method.call(result, _set_core, _cancel_core)
							4: await _method.call(result, _set_core, _cancel_core, cancel)
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT")
						.format([antecedent]))
					breakpoint

func _set_core(result: Variant = null) -> void:
	if _method.is_valid():
		release_complete(result)
	else:
		release_cancel()

func _cancel_core() -> void:
	release_cancel()
