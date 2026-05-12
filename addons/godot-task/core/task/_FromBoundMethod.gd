extends MonitoredCustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	method: Callable,
	bind_args: Array,
	name := &"Task.from_bound_method") -> Task:

	#
	# 事前チェック
	#

	if bind_args.is_empty():
		return _FROM_METHOD_CLASS.create(method, name)
	if not method.is_valid():
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT_ASSOCIATED_WITH_METHOD")
		return _CANCELED_CLASS.create(name)
	var method_argc := method.get_argument_count()
	match method_argc - bind_args.size():
		0:
			if not _is_valid_method_0(method, bind_args):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method.get_method())
				return _CANCELED_CLASS.create(name)
		1:
			if not _is_valid_method_1(method, bind_args):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method.get_method())
				return _CANCELED_CLASS.create(name)
		_:
			_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_COUNT", method.get_method(), method_argc - bind_args.size())
			return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(method, method_argc, bind_args, name)

func is_indefinitely_pending() -> bool:
	return not _method.is_valid()

func finalize() -> void:
	pass

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")
const _FROM_METHOD_CLASS := preload("uid://dxdjtx2f1e176")

var _method: Callable

static func _is_valid_method_0(method: Callable, bind_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation() and \
		not _AUTOLOAD_CLASS.is_lambda(method):

		var object := method.get_object()
		var method_name := method.get_method()
		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		for index: int in bind_args.size():
			var bind_arg: Variant = bind_args[index]
			if typeof(bind_arg) not in _AUTOLOAD_CLASS.VALID_ARG_TYPES_MAP[method_info_args[index].type]:
				return false
	return true

static func _is_valid_method_1(method: Callable, bind_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation() and \
		not _AUTOLOAD_CLASS.is_lambda(method):

		var object := method.get_object()
		var method_name := method.get_method()
		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		for index: int in bind_args.size():
			var bind_arg: Variant = bind_args[index]
			if typeof(bind_arg) not in _AUTOLOAD_CLASS.VALID_ARG_TYPES_MAP[method_info_args[index].type]:
				return false
		match method_info_args.back().type:
			TYPE_NIL, \
			TYPE_CALLABLE:
				pass
			_:
				return false
	return true

func _init(
	method: Callable,
	method_argc: int,
	bind_args: Array,
	name: StringName) -> void:

	super(name)

	_method = method
	_fork(method_argc, bind_args)

func _fork(method_argc: int, bind_args: Array) -> void:
	var result: Variant
	match method_argc - bind_args.size():
		0:
			result = await _method.callv(bind_args)
		1:
			result = await _method.callv(bind_args + [release_cancel])
	if is_pending():
		if _method.is_valid():
			release_complete(result)
		else:
			release_cancel()
