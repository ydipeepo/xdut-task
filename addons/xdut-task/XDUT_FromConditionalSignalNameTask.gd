class_name XDUT_FromConditionalSignalNameTask extends XDUT_FromSignalNameTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create_conditional(
	object: Object,
	signal_name: StringName,
	signal_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromConditionalSignalNameTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not is_instance_valid(object):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT"))
		return XDUT_CanceledTask.new(name)
	if not object.has_signal(signal_name):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_SIGNAL_NAME")
			.format([signal_name]))
		return XDUT_CanceledTask.new(name)
	if MAX_SIGNAL_ARGC < signal_args.size():
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_SIGNAL_ARGC")
			.format([signal_name, signal_args.size()]))
		return XDUT_CanceledTask.new(name)

	return new(
		object,
		signal_name,
		signal_args,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _signal_args: Array

static func _match(a: Variant, b: Variant) -> bool:
	match typeof(a):
		TYPE_OBJECT:
			if a == SKIP:
				return true
		TYPE_STRING, \
		TYPE_STRING_NAME:
			match typeof(b):
				TYPE_STRING, \
				TYPE_STRING_NAME:
					if a == b:
						return true
		_:
			if typeof(a) == typeof(b) and a == b:
				return true
	return false

func _init(
	object: Object,
	signal_name: StringName,
	signal_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(
		object,
		signal_name,
		signal_args.size(),
		cancel,
		name)

	_signal_args = signal_args

func _on_completed_1(arg1: Variant) -> void:
	if _match(_signal_args[0], arg1):
		super(arg1)

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2):
		super(arg1, arg2)

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3):
		super(arg1, arg2, arg3)

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3) and _match(_signal_args[3], arg4):
		super(arg1, arg2, arg3, arg4)

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3) and _match(_signal_args[3], arg4) and _match(_signal_args[4], arg5):
		super(arg1, arg2, arg3, arg4, arg5)
