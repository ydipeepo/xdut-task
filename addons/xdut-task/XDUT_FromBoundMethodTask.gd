class_name XDUT_FromBoundMethodTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	method: Callable,
	method_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromBoundMethodTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if method_args.is_empty():
		return XDUT_FromMethodTask.create(
			method,
			cancel,
			true,
			name)

	if not method.is_valid():
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD"))
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc - method_args.size():
		0, 1:
			pass
		_:
			push_error(internal_task_get_canonical()
				.translate(&"ERROR_BAD_METHOD_ARGC")
				.format([method.get_method(), method_argc]))
			return XDUT_CanceledTask.new(name)

	return new(
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
	method: Callable,
	method_argc: int,
	method_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_method = method
	_perform(method_argc, method_args, cancel)

func _perform(
	method_argc: int,
	method_args: Array,
	cancel: Cancel) -> void:

	var result: Variant
	match method_argc - method_args.size():
		0: result = await _method.callv(method_args)
		1: result = await _method.callv(method_args + [cancel])
	if _method.is_valid():
		release_complete(result)
	else:
		release_cancel()
