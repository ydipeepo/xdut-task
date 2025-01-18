class_name XDUT_ThenMethodNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenMethodNameTask") -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return XDUT_CanceledTask.new(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc:
		0, 1, 2:
			pass
		_:
			push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
			return XDUT_CanceledTask.new(name)

	return new(
		source_awaitable,
		object,
		method_name,
		method_argc,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _object: Object

func _init(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	method_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_object = object
	_perform(source_awaitable, method_name, method_argc, cancel)

func _perform(
	source_awaitable: Awaitable,
	method_name: StringName,
	method_argc: int,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
			STATE_COMPLETED:
				if is_instance_valid(_object):
					match method_argc:
						0: result = await _object.call(method_name)
						1: result = await _object.call(method_name, result)
						2: result = await _object.call(method_name, result, cancel)
					if is_pending:
						release_complete(result)
				else:
					release_cancel()
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source_awaitable)
