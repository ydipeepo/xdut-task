class_name XDUT_DeferTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	return new(
		cancel,
		name)

#-------------------------------------------------------------------------------

func _init(
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_on_completed.call_deferred()

func _on_completed() -> void:
	release_complete()
