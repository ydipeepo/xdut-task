class_name XDUT_DeferProcessFrameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferProcessFrameTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	return new(cancel, name)

func cleanup() -> void:
	var canonical := internal_get_task_canonical()
	if canonical.process_frame.is_connected(_on_completed):
		canonical.process_frame.disconnect(_on_completed)
	super()

#-------------------------------------------------------------------------------

func _init(cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	internal_get_task_canonical() \
		.process_frame \
		.connect(_on_completed)

func _on_completed(delta: float) -> void:
	release_complete(delta)
