class_name XDUT_FromSignalNameTask extends TaskBase

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	signal_name: StringName,
	signal_argc: int,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromSignalNameTask") -> Task:

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
	if signal_argc < 0 and MAX_SIGNAL_ARGC < signal_argc:
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_SIGNAL_ARGC")
			.format([signal_name, signal_argc]))
		return XDUT_CanceledTask.new(name)

	return new(
		object,
		signal_name,
		signal_argc,
		cancel,
		name)

func cleanup() -> void:
	if is_instance_valid(_object):
		match _signal_argc:
			0:
				if _object.is_connected(_signal_name, _on_completed_0):
					_object.disconnect(_signal_name, _on_completed_0)
			1:
				if _object.is_connected(_signal_name, _on_completed_1):
					_object.disconnect(_signal_name, _on_completed_1)
			2:
				if _object.is_connected(_signal_name, _on_completed_2):
					_object.disconnect(_signal_name, _on_completed_2)
			3:
				if _object.is_connected(_signal_name, _on_completed_3):
					_object.disconnect(_signal_name, _on_completed_3)
			4:
				if _object.is_connected(_signal_name, _on_completed_4):
					_object.disconnect(_signal_name, _on_completed_4)
			5:
				if _object.is_connected(_signal_name, _on_completed_5):
					_object.disconnect(_signal_name, _on_completed_5)
	super()

#-------------------------------------------------------------------------------

var _object: Object
var _signal_name: StringName
var _signal_argc: int

func _init(
	object: Object,
	signal_name: StringName,
	signal_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_object = object
	_signal_name = signal_name
	_signal_argc = signal_argc
	match _signal_argc:
		0: _object.connect(_signal_name, _on_completed_0)
		1: _object.connect(_signal_name, _on_completed_1)
		2: _object.connect(_signal_name, _on_completed_2)
		3: _object.connect(_signal_name, _on_completed_3)
		4: _object.connect(_signal_name, _on_completed_4)
		5: _object.connect(_signal_name, _on_completed_5)

func _on_completed_0() -> void:
	if is_pending:
		release_complete([])

func _on_completed_1(arg1: Variant) -> void:
	if is_pending:
		release_complete([arg1])

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if is_pending:
		release_complete([arg1, arg2])

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if is_pending:
		release_complete([arg1, arg2, arg3])

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if is_pending:
		release_complete([arg1, arg2, arg3, arg4])

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if is_pending:
		release_complete([arg1, arg2, arg3, arg4, arg5])
