class_name XDUT_DeferProcessTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferProcessTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	return new(cancel, name)

func cleanup() -> void:
	var canonical := internal_task_get_canonical()
	if canonical.process.is_connected(_on_completed):
		canonical.process.disconnect(_on_completed)
	super()

#-------------------------------------------------------------------------------

func _init(
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	internal_task_get_canonical() \
		.process \
		.connect(_on_completed)

func _on_completed(delta: float) -> void:
	release_complete(delta)
