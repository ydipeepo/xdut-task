class_name XDUT_FromBoundMethodNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromBoundMethodNameTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if method_args.is_empty():
		return XDUT_FromMethodNameTask.create(
			object,
			method_name,
			cancel,
			true,
			name)

	if not is_instance_valid(object):
		push_error("Invalid object.")
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return XDUT_CanceledTask.new(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc - method_args.size():
		0, 1:
			pass
		_:
			push_error("Invalid method argument count: ", method_argc)
			return XDUT_CanceledTask.new(name)

	return new(
		object,
		method_name,
		method_argc,
		method_args,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _object: Object

func _init(
	object: Object,
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_object = object
	_perform(method_name, method_argc, method_args, cancel)

func _perform(
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel) -> void:

	var result: Variant
	match method_argc - method_args.size():
		0: result = await _object.callv(method_name, method_args)
		1: result = await _object.callv(method_name, method_args + [cancel])
	if is_pending:
		release_complete(result)
