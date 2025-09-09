class_name XDUT_LoadTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	resource_path: String,
	resource_type: StringName,
	cache_mode: ResourceLoader.CacheMode,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"LoadTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	return new(
		resource_path,
		resource_type,
		cache_mode,
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
	cache_mode: ResourceLoader.CacheMode,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_worker = XDUT_LoadTaskWorker.create(
		internal_task_get_canonical(),
		resource_path,
		resource_type,
		cache_mode)
	if _worker == null:
		release_cancel()
		return
	_worker.loaded.connect(release_complete)
	_worker.failed.connect(release_cancel)
