extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent_task: Awaitable,
	object: Object,
	method_name: StringName,
	bind_args: Array,
	name := &"Task.then_bound_method_name") -> Task:

	#
	# 事前チェック
	#

	if bind_args.is_empty():
		return _THEN_METHOD_NAME_CLASS.create(
			antecedent_task,
			object,
			method_name,
			name)
	if not is_instance_valid(object):
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT")
		return _CANCELED_CLASS.create(name)
	if not object.has_method(method_name):
		_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_NAME", method_name)
		return _CANCELED_CLASS.create(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc - bind_args.size():
		0:
			if not _is_valid_method_name_0(object, method_name, bind_args):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method_name)
				return _CANCELED_CLASS.create(name)
		1:
			if not _is_valid_method_name_1(object, method_name, bind_args):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method_name)
				return _CANCELED_CLASS.create(name)
		2:
			if not _is_valid_method_name_2(object, method_name, bind_args):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method_name)
				return _CANCELED_CLASS.create(name)
		_:
			_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_COUNT", method_name, method_argc)
			return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(
		antecedent_task,
		object,
		method_name,
		method_argc,
		bind_args,
		name)

func finalize() -> void:
	if _antecedent_task is CustomTask:
		_antecedent_task.temporary_release(self)
	_antecedent_task = null
	_object = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")
const _THEN_METHOD_NAME_CLASS := preload("uid://cn048monfibu6")

var _antecedent_task: Awaitable
var _object: Object

static func _is_valid_method_name_0(object: Object, method_name: StringName, bind_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation():

		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		for index: int in bind_args.size():
			var bind_arg: Variant = bind_args[index]
			if typeof(bind_arg) not in _AUTOLOAD_CLASS.VALID_ARG_TYPES_MAP[method_info_args[index].type]:
				return false
	return true

static func _is_valid_method_name_1(object: Object, method_name: StringName, bind_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation():

		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		for index: int in bind_args.size():
			var bind_arg: Variant = bind_args[index]
			if typeof(bind_arg) not in _AUTOLOAD_CLASS.VALID_ARG_TYPES_MAP[method_info_args[index].type]:
				return false
	return true

static func _is_valid_method_name_2(object: Object, method_name: StringName, bind_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation():

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
	antecedent_task: Awaitable,
	object: Object,
	method_name: StringName,
	method_argc: int,
	bind_args: Array,
	name: StringName) -> void:

	super(name)

	_antecedent_task = antecedent_task
	_object = object
	_fork(method_name, method_argc, bind_args)

func _fork(
	method_name: StringName,
	method_argc: int,
	bind_args: Array) -> void:

	var result: Variant = \
		await _antecedent_task.temporary_wait(self) \
		if _antecedent_task is CustomTask else \
		await _antecedent_task.wait(get_cascade_cancel())
	if is_pending():
		if _antecedent_task is Task:
			match _antecedent_task.get_state():
				STATE_COMPLETED:
					match method_argc - bind_args.size():
						0:
							result = await _object.callv(method_name, bind_args)
						1:
							result = await _object.callv(method_name, bind_args + [result])
						2:
							result = await _object.callv(method_name, bind_args + [result, release_cancel])
					if is_pending():
						release_complete(result)
				STATE_CANCELED:
					release_cancel()
				_:
					if not _antecedent_task is CustomTask or not _antecedent_task.is_pending():
						_AUTOLOAD_CLASS.print_error(&"UNKNOWN_STATE_RETURNED_BY_ANTECEDENT", _antecedent_task)
						breakpoint
					release_cancel()
		else:
			match method_argc - bind_args.size():
				0:
					result = await _object.callv(method_name, bind_args)
				1:
					result = await _object.callv(method_name, bind_args + [result])
				2:
					result = await _object.callv(method_name, bind_args + [result, release_cancel])
			if is_pending():
				release_complete(result)
