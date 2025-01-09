class_name XDUT_DeferPhysicsFrameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferPhysicsFrameTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	return new(
		cancel,
		name)

func cleanup() -> void:
	var canonical := get_canonical()
	if canonical != null:
		if canonical.physics_frame.is_connected(_on_completed):
			canonical.physics_frame.disconnect(_on_completed)
	super()

#-------------------------------------------------------------------------------

func _init(
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	var canonical := get_canonical()
	if canonical != null:
		canonical.physics_frame.connect(_on_completed)
	else:
		release_cancel()

func _on_completed(delta: float) -> void:
	release_complete(delta)
