class_name XDUT_NeverTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"NeverTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	return new(cancel, name)

#-------------------------------------------------------------------------------

func _init(cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
