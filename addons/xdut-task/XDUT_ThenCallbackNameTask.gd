class_name XDUT_ThenCallbackNameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenCallbackNameTask") -> Task:

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
	if not object.get_method_argument_count(method_name) in _VALID_METHOD_ARGC:
		push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
		return XDUT_CanceledTask.new(name)

	return new(
		source_awaitable,
		object,
		method_name,
		cancel,
		name)

#-------------------------------------------------------------------------------

const _VALID_METHOD_ARGC: Array[int] = [2, 3, 4]

var _object: Object
var _method_name: StringName

func _init(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	_object = object
	_method_name = method_name
	_perform(source_awaitable, cancel)

func _perform(
	source_awaitable: Awaitable,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
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
				error_bad_state(source_awaitable)
