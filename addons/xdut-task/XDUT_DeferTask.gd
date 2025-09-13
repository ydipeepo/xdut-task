class_name XDUT_DeferTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DeferTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	return new(cancel, name)

#-------------------------------------------------------------------------------

func _init(cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	_on_completed.call_deferred()

func _on_completed() -> void:
	release_complete()
