class_name XDUT_FromCallbackTask extends XDUT_TaskBase

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
		push_error("Invalid object associated with method.")
		return XDUT_CanceledTask.new(name)
	var method_argc := method.get_argument_count()
	match method_argc:
		1, 2, 3:
			pass
		_:
			push_error("Invalid method argument count: ", method.get_argument_count())
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

	super(cancel, true, name)
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
