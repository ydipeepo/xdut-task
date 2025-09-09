class_name XDUT_ThenMethodNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenMethodNameTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(source) or source.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if not is_instance_valid(object):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT"))
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_METHOD_NAME")
			.format([method_name]))
		return XDUT_CanceledTask.new(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc:
		0, 1, 2:
			pass
		_:
			push_error(internal_task_get_canonical()
				.translate(&"ERROR_BAD_METHOD_ARGC")
				.format([method_name, method_argc]))
			return XDUT_CanceledTask.new(name)
	return new(
		source,
		object,
		method_name,
		method_argc,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _object: Object

func _init(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	method_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_object = object
	_perform(source, method_name, method_argc, cancel)

func _perform(
	source: Awaitable,
	method_name: StringName,
	method_argc: int,
	cancel: Cancel) -> void:

	var result: Variant = await source.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match source.get_state():
				STATE_COMPLETED:
					if is_instance_valid(_object):
						match method_argc:
							0: result = await _object.call(method_name)
							1: result = await _object.call(method_name, result)
							2: result = await _object.call(method_name, result, cancel)
						release_complete(result)
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					assert(false, internal_task_get_canonical()
						.translate(&"ERROR_BAD_STATE")
						.format([source]))
