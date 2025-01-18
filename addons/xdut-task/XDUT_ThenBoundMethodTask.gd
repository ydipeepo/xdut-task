class_name XDUT_ThenBoundMethodTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	method: Callable,
	method_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenBoundMethodTask") -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if method_args.is_empty():
		return XDUT_ThenMethodTask.create(
			source_awaitable,
			method,
			cancel,
			true,
			name)

	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc - method_args.size():
		0, 1, 2:
			pass
		_:
			push_error("Invalid method argument count: ", method.get_argument_count())
			return XDUT_CanceledTask.new(name)

	return new(
		source_awaitable,
		method,
		method_argc,
		method_args,
		cancel,
		name)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

var _method: Callable

func _init(
	source_awaitable: Awaitable,
	method: Callable,
	method_argc: int,
	method_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_method = method
	_perform(source_awaitable, method_argc, method_args, cancel)

func _perform(
	source_awaitable: Awaitable,
	method_argc: int,
	method_args: Array,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
			STATE_COMPLETED:
				if _method.is_valid():
					match method_argc - method_args.size():
						0: result = await _method.callv(method_args)
						1: result = await _method.callv(method_args + [result])
						2: result = await _method.callv(method_args + [result, cancel])
					if is_pending:
						if _method.is_valid():
							release_complete(result)
						else:
							release_cancel()
				else:
					release_cancel()
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source_awaitable)
