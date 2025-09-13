class_name XDUT_ThenBoundMethodNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent: Awaitable,
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenBoundMethodNameTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(antecedent) or antecedent.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if method_args.is_empty():
		return XDUT_ThenMethodNameTask.create(
			antecedent,
			object,
			method_name,
			cancel,
			true,
			name)
	if not is_instance_valid(object):
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_OBJECT"))
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_METHOD_NAME")
			.format([method_name]))
		return XDUT_CanceledTask.new(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc - method_args.size():
		0, 1, 2:
			pass
		_:
			push_error(internal_get_task_canonical()
				.translate(&"ERROR_BAD_METHOD_ARGC")
				.format([method_name, method_argc]))
			return XDUT_CanceledTask.new(name)
	return new(
		antecedent,
		object,
		method_name,
		method_argc,
		method_args,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _object: Object

func _init(
	antecedent: Awaitable,
	object: Object,
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_object = object
	_perform(antecedent, method_name, method_argc, method_args, cancel)

func _perform(
	antecedent: Awaitable,
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel) -> void:

	var result: Variant = await antecedent.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match antecedent.get_state():
				STATE_COMPLETED:
					if is_instance_valid(_object):
						match method_argc - method_args.size():
							0: result = await _object.callv(method_name, method_args)
							1: result = await _object.callv(method_name, method_args + [result])
							2: result = await _object.callv(method_name, method_args + [result, cancel])
						release_complete(result)
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT")
						.format([antecedent]))
					breakpoint
