class_name XDUT_FromMethodTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	method: Callable,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromMethodTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not method.is_valid():
		push_error(get_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD"))
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc:
		0, 1:
			pass
		_:
			push_error(get_canonical()
				.translate(&"ERROR_BAD_METHOD_ARGC")
				.format([method.get_method(), method_argc]))
			return XDUT_CanceledTask.new(name)

	return new(
		method,
		method_argc,
		cancel,
		name)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

var _method: Callable

func _init(
	method: Callable,
	method_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_method = method
	_perform(method_argc, cancel)

func _perform(
	method_argc: int,
	cancel: Cancel) -> void:

	var result: Variant
	match method_argc:
		0: result = await _method.call()
		1: result = await _method.call(cancel)
	if _method.is_valid():
		release_complete(result)
	else:
		release_cancel()
