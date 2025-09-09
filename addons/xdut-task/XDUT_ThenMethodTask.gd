class_name XDUT_ThenMethodTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source: Awaitable,
	method: Callable,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenMethodTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(source) or source.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if not method.is_valid():
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD"))
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc:
		0, 1, 2:
			pass
		_:
			push_error(internal_task_get_canonical()
				.translate(&"ERROR_BAD_METHOD_ARGC")
				.format([method.get_method(), method_argc]))
			return XDUT_CanceledTask.new(name)
	return new(
		source,
		method,
		method_argc,
		cancel,
		name)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

var _method: Callable

func _init(
	source: Awaitable,
	method: Callable,
	method_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_method = method
	_perform(source, method_argc, cancel)

func _perform(source: Awaitable, method_argc: int, cancel: Cancel) -> void:
	var result: Variant = await source.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match source.get_state():
				STATE_COMPLETED:
					if _method.is_valid():
						match method_argc:
							0: result = await _method.call()
							1: result = await _method.call(result)
							2: result = await _method.call(result, cancel)
						if _method.is_valid():
							release_complete(result)
						else:
							release_cancel()
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					assert(false, internal_task_get_canonical()
						.translate(&"ERROR_BAD_STATE")
						.format([source]))
