class_name XDUT_LoadTaskWorker

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

signal loaded(resource: Variant)
signal failed

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	canonical: Node,
	resource_path: String,
	resource_type: StringName,
	cache_mode: ResourceLoader.CacheMode) -> XDUT_LoadTaskWorker:

	assert(canonical != null)
	var result := ResourceLoader.load_threaded_request(
		resource_path,
		resource_type,
		true,
		cache_mode)
	if result != OK:
		return null
	return new(canonical, resource_path)

#-------------------------------------------------------------------------------

var _canonical: Node
var _resource_path: String

func _init(canonical: Node, resource_path: String) -> void:
	reference()
	_resource_path = resource_path
	_canonical = canonical
	_canonical.process_frame.connect(_on_process)

func _on_process(delta: float) -> void:
	match ResourceLoader.load_threaded_get_status(_resource_path):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			if is_instance_valid(_canonical):
				_canonical.process_frame.disconnect(_on_process)
			printerr(_canonical
				.translate(&"ERROR_BAD_RESOURCE")
				.format([_resource_path]))
			failed.emit()
			unreference()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_FAILED:
			if is_instance_valid(_canonical):
				_canonical.process_frame.disconnect(_on_process)
			printerr(_canonical
				.translate(&"ERROR_BAD_RESOURCE_INTERNAL")
				.format([_resource_path]))
			failed.emit()
			unreference()
		ResourceLoader.THREAD_LOAD_LOADED:
			if is_instance_valid(_canonical):
				_canonical.process_frame.disconnect(_on_process)
			var resource := ResourceLoader.load_threaded_get(_resource_path)
			loaded.emit(resource)
			unreference()
