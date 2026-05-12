extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	method_name: StringName,
	name := &"Task.from_method_name") -> Task:

	#
	# 事前チェック
	#

	if not is_instance_valid(object):
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT")
		return _CANCELED_CLASS.create(name)
	if not object.has_method(method_name):
		_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_NAME", method_name)
		return _CANCELED_CLASS.create(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc:
		0:
			if not _is_valid_method_name_0(object, method_name):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method_name)
				return _CANCELED_CLASS.create(name)
		1:
			if not _is_valid_method_name_1(object, method_name):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method_name)
				return _CANCELED_CLASS.create(name)
		_:
			_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_COUNT", method_name, method_argc)
			return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(object, method_name, method_argc, name)

func finalize() -> void:
	_object = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

var _object: Object

@warning_ignore("unused_parameter")
static func _is_valid_method_name_0(object: Object, method_name: StringName) -> bool:
	return true

static func _is_valid_method_name_1(object: Object, method_name: StringName) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation():

		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		match method_info_args[0].type:
			TYPE_NIL, \
			TYPE_CALLABLE:
				pass
			_:
				return false
	return true

func _init(
	object: Object,
	method_name: StringName,
	method_argc: int,
	name: StringName) -> void:

	super(name)

	_object = object
	_fork(method_name, method_argc)

func _fork(method_name: StringName, method_argc: int) -> void:
	var result: Variant
	match method_argc:
		0:
			result = await _object.call(method_name)
		1:
			result = await _object.call(method_name, release_cancel)
	if is_pending():
		release_complete(result)
