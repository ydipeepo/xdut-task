class_name XDUT_FromCallbackNameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	method_name: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromCallbackNameTask") -> Task:

	if not skip_pre_validation:
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
		1, 2, 3:
			pass
		_:
			push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
			return XDUT_CanceledTask.new(name)

	return new(
		object,
		method_name,
		method_argc,
		cancel,
		name)

#--------------------------------------------------------------------------------

var _object: Object

func _init(
	object: Object,
	method_name: StringName,
	method_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	_object = object
	_perform(method_name, method_argc, cancel)

func _perform(
	method_name: StringName,
	method_argc: int,
	cancel: Cancel) -> void:

	match method_argc:
		1: await _object.call(method_name, release_complete)
		2: await _object.call(method_name, release_complete, release_cancel)
		3: await _object.call(method_name, release_complete, release_cancel, cancel)
