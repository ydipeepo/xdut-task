extends CustomTask

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

enum {
	METHOD_GET = HTTPClient.METHOD_GET,
	METHOD_HEAD = HTTPClient.METHOD_HEAD,
	METHOD_POST = HTTPClient.METHOD_POST,
	METHOD_PUT = HTTPClient.METHOD_PUT,
	METHOD_DELETE = HTTPClient.METHOD_DELETE,
	METHOD_OPTIONS = HTTPClient.METHOD_OPTIONS,
	#METHOD_TRACE = HTTPClient.METHOD_TRACE,
	#METHOD_CONNECT = HTTPClient.METHOD_CONNECT,
	METHOD_PATCH = HTTPClient.METHOD_PATCH,
}

#-------------------------------------------------------------------------------
#	CLASSES
#-------------------------------------------------------------------------------

class Worker extends HTTPRequest:

	signal completed(response: Dictionary)
	signal aborted

	var url: String
	var headers: PackedStringArray
	var method: HTTPClient.Method
	var body: String

	func abort() -> void:
		if not _emitted:
			_emitted = true
			aborted.emit()
			queue_free()

	var _emitted: bool

	func _init() -> void:
		name = "Worker_HTTPTask-%s" % String.num_uint64(get_instance_id(), 16, true)
		request_completed.connect(_on_request_completed)

	func _ready() -> void:
		var error := request(url, headers, method, body)
		if error != OK:
			if is_inside_tree():
				get_parent().remove_child(self)
			if not _emitted:
				_emitted = true
				aborted.emit()
			free()

	func _on_request_completed(
		result: int,
		status_code: int,
		headers: PackedStringArray,
		body: PackedByteArray) -> void:

		match result:
			RESULT_SUCCESS:
				if not _emitted:
					_emitted = true
					completed.emit({
						&"status_code": status_code,
						&"headers": headers,
						&"body": body,
					})
			_:
				if not _emitted:
					_emitted = true
					aborted.emit()
		queue_free()

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	method: int,
	url: String,
	headers: PackedStringArray,
	body := "",
	timeout := 0.0,
	name := &"Task.http") -> Task:

	#
	# 事前チェック
	#

	if not _AUTOLOAD_CLASS.has_current():
		_AUTOLOAD_CLASS.print_error(&"ADDON_NOT_READY")
		return _CANCELED_CLASS.create(name)
	if timeout < 0.0:
		_AUTOLOAD_CLASS.print_error(&"BAD_TIMEOUT")
		return _CANCELED_CLASS.create(name)
	var worker: Worker
	worker = Worker.new()
	worker.url = url
	worker.headers = headers
	worker.method = method
	worker.body = body
	worker.timeout = timeout
	_AUTOLOAD_CLASS.get_current().add_child(worker)

	#
	# タスク作成
	#

	return new(worker, name)

func finalize() -> void:
	_worker.abort()
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
