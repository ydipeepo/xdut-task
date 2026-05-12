extends CustomTask

#-------------------------------------------------------------------------------
#	CLASSES
#-------------------------------------------------------------------------------

class Worker extends Node:

	signal completed(resource: Variant)
	signal aborted

	var resource_path: String
	var resource_type: StringName

	func _init() -> void:
		name = "Worker_LoadTask-%s" % String.num_uint64(get_instance_id(), 16, true)

	func _process(delta: float) -> void:
		var status := ResourceLoader.load_threaded_get_status(resource_path)
		match status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				if is_inside_tree():
					_AUTOLOAD_CLASS.print_error(
						&"TASK_RESOURCE_LOADER_BAD_RESOURCE",
						resource_path,
						resource_type)
					get_parent().remove_child(self)
				aborted.emit()
				free()
			#ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			#	pass
			ResourceLoader.THREAD_LOAD_FAILED:
				if is_inside_tree():
					_AUTOLOAD_CLASS.print_error(
						&"TASK_RESOURCE_LOADER_FAILED",
						resource_path,
						resource_type)
					get_parent().remove_child(self)
				aborted.emit()
				free()
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource := ResourceLoader.load_threaded_get(resource_path)
				if is_inside_tree():
					get_parent().remove_child(self)
				completed.emit(resource)
				free()

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	resource_path: String,
	resource_type: StringName,
	cache_mode: ResourceLoader.CacheMode,
	name := &"Task.load") -> Task:

	#
	# 事前チェック
	#

	if not _AUTOLOAD_CLASS.has_current():
		_AUTOLOAD_CLASS.print_error(&"ADDON_NOT_READY")
		return _CANCELED_CLASS.create(name)
	var worker: Worker
	for worker_candidate: Node in _AUTOLOAD_CLASS.get_current().get_children():
		if \
			worker_candidate is Worker and \
			worker_candidate.resource_path == resource_path and \
			worker_candidate.resource_type == resource_type:
			worker = worker_candidate
			break
	if worker == null:
		var error := ResourceLoader.load_threaded_request(
			resource_path,
			resource_type,
			true,
			cache_mode)
		if error == OK:
			worker = Worker.new()
			worker.resource_path = resource_path
			worker.resource_type = resource_type
			_AUTOLOAD_CLASS.get_current().add_child(worker)
	if worker == null:
		return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(worker, name)

func finalize() -> void:
	_worker.completed.disconnect(release_complete)
	_worker.aborted.disconnect(release_cancel)
	_worker = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

var _worker: Worker

func _init(worker: Worker, name: StringName) -> void:
	super(name)

	_worker = worker
	_worker.completed.connect(release_complete)
	_worker.aborted.connect(release_cancel)
