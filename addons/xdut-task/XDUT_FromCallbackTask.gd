class_name XDUT_FromCallbackTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	method: Callable,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromCallbackTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not method.is_valid():
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD"))
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc:
		1, 2, 3:
			pass
		_:
			push_error(internal_task_get_canonical()
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

	match method_argc:
		1: await _method.call(_set_core)
		2: await _method.call(_set_core, _cancel_core)
		3: await _method.call(_set_core, _cancel_core, cancel)

func _set_core(result: Variant = null) -> void:
	if _method.is_valid():
		release_complete(result)
	else:
		release_cancel()

func _cancel_core() -> void:
	release_cancel()
