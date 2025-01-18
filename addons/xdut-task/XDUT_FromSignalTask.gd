class_name XDUT_FromSignalTask extends MonitoredTaskBase

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	signal_: Signal,
	signal_argc: int,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromSignalTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not is_instance_valid(signal_.get_object()) or signal_.is_null():
		push_error("Invalid object associated with signal.")
		return XDUT_CanceledTask.new(name)
	if signal_argc < 0 and MAX_SIGNAL_ARGC < signal_argc:
		push_error("Invalid signal argument count: ", signal_argc)
		return XDUT_CanceledTask.new(name)

	return new(
		signal_,
		signal_argc,
		cancel,
		name)

func is_indefinitely_pending() -> bool:
	return is_pending and not is_instance_valid(_signal.get_object()) or _signal.is_null()

func cleanup() -> void:
	if is_instance_valid(_signal.get_object()) and not _signal.is_null():
		match _signal_argc:
			0:
				if _signal.is_connected(_on_completed_0):
					_signal.disconnect(_on_completed_0)
			1:
				if _signal.is_connected(_on_completed_1):
					_signal.disconnect(_on_completed_1)
			2:
				if _signal.is_connected(_on_completed_2):
					_signal.disconnect(_on_completed_2)
			3:
				if _signal.is_connected(_on_completed_3):
					_signal.disconnect(_on_completed_3)
			4:
				if _signal.is_connected(_on_completed_4):
					_signal.disconnect(_on_completed_4)
			5:
				if _signal.is_connected(_on_completed_5):
					_signal.disconnect(_on_completed_5)
	super()

#-------------------------------------------------------------------------------

var _signal: Signal
var _signal_argc: int

func _init(
	signal_: Signal,
	signal_argc: int,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_signal = signal_
	_signal_argc = signal_argc
	match _signal_argc:
		0: _signal.connect(_on_completed_0)
		1: _signal.connect(_on_completed_1)
		2: _signal.connect(_on_completed_2)
		3: _signal.connect(_on_completed_3)
		4: _signal.connect(_on_completed_4)
		5: _signal.connect(_on_completed_5)

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
