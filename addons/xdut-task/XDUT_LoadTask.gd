class_name XDUT_LoadTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	resource_path: String,
	resource_type: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"LoadTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	return new(
		resource_path,
		resource_type,
		cancel,
		name)

func cleanup() -> void:
	if _worker != null:
		_worker.loaded.disconnect(release_complete)
		_worker.failed.disconnect(release_cancel)
		_worker = null
	super()

#-------------------------------------------------------------------------------

var _worker: XDUT_LoadTaskWorker

func _init(
	resource_path: String,
	resource_type: StringName,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	var canonical := get_canonical()
	if canonical == null:
		release_cancel()
		return

	_worker = XDUT_LoadTaskWorker.create(
		canonical,
		resource_path,
		resource_type)
	if _worker == null:
		release_cancel()
		return

	_worker.loaded.connect(release_complete)
	_worker.failed.connect(release_cancel)
