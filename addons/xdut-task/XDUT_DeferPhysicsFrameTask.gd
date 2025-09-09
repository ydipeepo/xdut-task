class_name XDUT_DeferPhysicsFrameTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferPhysicsFrameTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	return new(cancel, name)

func cleanup() -> void:
	var canonical := internal_task_get_canonical()
	if canonical.physics_frame.is_connected(_on_completed):
		canonical.physics_frame.disconnect(_on_completed)
	super()

#-------------------------------------------------------------------------------

func _init(cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	internal_task_get_canonical() \
		.physics_frame \
		.connect(_on_completed)

func _on_completed(delta: float) -> void:
	release_complete(delta)
