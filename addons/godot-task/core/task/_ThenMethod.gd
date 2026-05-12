extends MonitoredCustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent_task: Task,
	method: Callable,
	name := &"Task.then_method") -> Task:

	#
	# 事前チェック
	#

	if not method.is_valid():
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT_ASSOCIATED_WITH_METHOD")
		return _CANCELED_CLASS.create(name)
	var method_argc := method.get_argument_count()
	match method_argc:
		0:
			if not _is_valid_method_0(method):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method.get_method())
				return _CANCELED_CLASS.create(name)
		1:
			if not _is_valid_method_1(method):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method.get_method())
				return _CANCELED_CLASS.create(name)
		2:
			if not _is_valid_method_2(method):
				_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_SIGNATURE", method.get_method())
				return _CANCELED_CLASS.create(name)
		_:
			_AUTOLOAD_CLASS.print_error(&"BAD_METHOD_ARGUMENT_COUNT", method.get_method(), method_argc)
			return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(antecedent_task, method, method_argc, name)

func is_indefinitely_pending() -> bool:
	return not _method.is_valid()

func finalize() -> void:
	if _antecedent_task is CustomTask:
		_antecedent_task.temporary_release(self)
	_antecedent_task = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

var _antecedent_task: Awaitable
var _method: Callable

@warning_ignore("unused_parameter")
static func _is_valid_method_0(method: Callable) -> bool:
	return true

@warning_ignore("unused_parameter")
static func _is_valid_method_1(method: Callable) -> bool:
	return true

static func _is_valid_method_2(method: Callable) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_method_validation() and \
		not _AUTOLOAD_CLASS.is_lambda(method):

		var object := method.get_object()
		var method_name := method.get_method()
		var method_info := _AUTOLOAD_CLASS.get_method_info(object, method_name)
		var method_info_args: Array = method_info.args
		match method_info_args[2].type:
			TYPE_NIL, \
			TYPE_CALLABLE:
				pass
			_:
				return false
	return true

func _init(
	antecedent_task: Awaitable,
	method: Callable,
	method_argc: int,
	name: StringName) -> void:

	super(name)

	_antecedent_task = antecedent_task
	_method = method
	_fork(method_argc)

func _fork(method_argc: int) -> void:
	var result: Variant = \
		await _antecedent_task.temporary_wait(self) \
		if _antecedent_task is CustomTask else \
		await _antecedent_task.wait(get_cascade_cancel())
	if is_pending():
		if _antecedent_task is Task:
			match _antecedent_task.get_state():
				STATE_COMPLETED:
					if _method.is_valid():
						match method_argc:
							0:
								result = await _method.call()
							1:
								result = await _method.call(result)
							2:
								result = await _method.call(result, release_cancel)
						if is_pending():
							if _method.is_valid():
								release_complete(result)
							else:
								release_cancel()
					else:
						release_cancel()
				STATE_CANCELED:
					release_cancel()
				_:
					if not _antecedent_task is CustomTask or not _antecedent_task.is_pending():
						_AUTOLOAD_CLASS.print_error(&"UNKNOWN_STATE_RETURNED_BY_ANTECEDENT", _antecedent_task)
						breakpoint
					release_cancel()
		else:
			if _method.is_valid():
				match method_argc:
					0:
						result = await _method.call()
					1:
						result = await _method.call(result)
					2:
						result = await _method.call(result, release_cancel)
				if is_pending():
					if _method.is_valid():
						release_complete(result)
					else:
						release_cancel()
			else:
				release_cancel()
