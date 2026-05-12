extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	signal_name: StringName,
	name := &"Task.from_signal_name") -> Task:

	#
	# 事前チェック
	#

	if not is_instance_valid(object):
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT")
		return _CANCELED_CLASS.create(name)
	if not object.has_signal(signal_name):
		_AUTOLOAD_CLASS.print_error(&"BAD_SIGNAL_NAME", signal_name)
		return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(object, signal_name, name)

func finalize() -> void:
	_object.disconnect(_signal_name, _on_completed)
	_object = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

var _object: Object
var _signal_name: StringName

func _init(object: Object, signal_name: StringName, name: StringName) -> void:
	super(name)

	_signal_name = signal_name
	_object = object
	_object.connect(_signal_name, _on_completed)

func _on_completed(...args: Array) -> void:
	release_complete(args)
