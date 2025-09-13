class_name XDUT_ThenCallbackNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenCallbackNameTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(source) or source.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if not is_instance_valid(object):
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_OBJECT"))
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_METHOD_NAME")
			.format([method_name]))
		return XDUT_CanceledTask.new(name)
	if not object.get_method_argument_count(method_name) in _VALID_METHOD_ARGC:
		push_error(internal_get_task_canonical()
			.translate(&"ERROR_BAD_METHOD_ARGC")
			.format([method_name, object.get_method_argument_count(method_name)]))
		return XDUT_CanceledTask.new(name)
	return new(
		source,
		object,
		method_name,
		cancel,
		name)

#-------------------------------------------------------------------------------

const _VALID_METHOD_ARGC: Array[int] = [2, 3, 4]

var _object: Object
var _method_name: StringName

func _init(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_object = object
	_method_name = method_name
	_perform(source, cancel)

func _perform(source: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await source.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match source.get_state():
				STATE_COMPLETED:
					if is_instance_valid(_object):
						match _object.get_method_argument_count(_method_name):
							2: await _object.call(_method_name, result, release_complete)
							3: await _object.call(_method_name, result, release_complete, release_cancel)
							4: await _object.call(_method_name, result, release_complete, release_cancel, cancel)
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT")
						.format([source]))
					breakpoint
