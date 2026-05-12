extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(init_array: Array, name := &"Task.race") -> Task:
	#
	# 事前チェック
	#

	if init_array.is_empty():
		_AUTOLOAD_CLASS.print_error(&"EMPTY_INIT_ARRAY")
		return _NEVER_CLASS.create(name)

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
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")
const _FROM_CLASS := preload("uid://dy6eonb15bmuf")
const _NEVER_CLASS := preload("uid://dnj148hmipgia")

var _task_array: Array[Awaitable]

func _init(init_array: Array, name: StringName) -> void:
	super(name)

	var init_count := init_array.size()
	_task_array.resize(init_count)
	for index: int in init_count:
		if not is_pending():
			break
		var init: Variant = init_array[index]
		var task: Awaitable = \
			init \
			if init is Awaitable else \
			_FROM_CLASS.create(init_array[index])
		_task_array[index] = task
		_fork(task, index)

func _fork(task: Awaitable, index: int) -> void:
	var result: Variant = \
		await task.temporary_wait(self) \
		if task is CustomTask else \
		await task.wait(get_cascade_cancel())
	if is_pending():
		if task is Task:
			match task.get_state():
				STATE_COMPLETED:
					release_complete(_COMPLETED_CLASS.create(result))
				STATE_CANCELED:
					release_complete(_CANCELED_CLASS.create())
				_:
					if not task is CustomTask or not task.is_pending():
						_AUTOLOAD_CLASS.print_error(&"UNKNOWN_STATE_RETURNED_BY_INIT", task, index)
						breakpoint
					release_cancel()
		else:
			release_complete(_COMPLETED_CLASS.create(result))
