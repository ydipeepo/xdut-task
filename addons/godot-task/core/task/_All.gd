extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(init_array: Array, name := &"Task.all") -> Task:
	#
	# 事前チェック
	#

	if init_array.is_empty():
		return _COMPLETED_CLASS.create([], name)

	#
	# タスク作成
	#

	return new(init_array, name)

func finalize() -> void:
	for index: int in _task_array.size():
		var task := _task_array[index]
		if task is CustomTask:
			task.temporary_release(self)
	_task_array.clear()

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _COMPLETED_CLASS := preload("uid://cxtfk6753t3x5")
const _FROM_CLASS := preload("uid://dy6eonb15bmuf")

var _task_array: Array[Awaitable]
var _pending: int

func _init(init_array: Array, name: StringName) -> void:
	super(name)

	var init_count := init_array.size()
	var result_set := []; result_set.resize(init_count)
	_task_array.resize(init_count)
	_pending = init_count
	for index: int in init_count:
		if not is_pending():
			break
		var init: Variant = init_array[index]
		var task: Awaitable = \
			init \
			if init is Awaitable else \
			_FROM_CLASS.create(init)
		_task_array[index] = task
		_fork(task, index, result_set)

func _fork(task: Awaitable, index: int, result_set: Array) -> void:
	var result: Variant = \
		await task.temporary_wait(self) \
		if task is CustomTask else \
		await task.wait(get_cascade_cancel())
	if is_pending():
		if task is Task:
			match task.get_state():
				STATE_COMPLETED:
					result_set[index] = result
					_pending -= 1
					if _pending == 0:
						release_complete(result_set)
				STATE_CANCELED:
					release_cancel()
				_:
					if not task is CustomTask or not task.is_pending():
						_AUTOLOAD_CLASS.print_error(&"UNKNOWN_STATE_RETURNED_BY_INIT", task, index)
						breakpoint
					release_cancel()
		else:
			result_set[index] = result
			_pending -= 1
			if _pending == 0:
				release_complete(result_set)
