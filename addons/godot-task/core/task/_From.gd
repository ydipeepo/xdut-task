extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(init: Variant, name := &"Task.from") -> Task:
	if init is Array:
		match init.size():
			3 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					if init[2] is Array:
						return _FROM_BOUND_METHOD_NAME_CLASS.create(
							init[0],
							init[1],
							init[2],
							name)
				if init[0].has_signal(init[1]):
					if init[2] is Array:
						return _FROM_FILTERED_SIGNAL_NAME_CLASS.create(
							init[0],
							init[1],
							init[2],
							name)
			2 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					return _FROM_METHOD_NAME_CLASS.create(
						init[0],
						init[1],
						name)
				if init[0].has_signal(init[1]):
					return _FROM_SIGNAL_NAME_CLASS.create(
						init[0],
						init[1],
						name)
			2 when init[0] is Callable:
				if init[1] is Array:
					return _FROM_BOUND_METHOD_CLASS.create(
						init[0],
						init[1],
						name)
			2 when init[0] is Signal:
				if init[1] is Array:
					return _FROM_FILTERED_SIGNAL_CLASS.create(
						init[0],
						init[1],
						name)
			1 when init[0] is Object:
				if init[0] is Awaitable:
					return \
						_CANCELED_CLASS.create(name) \
						if init[0].is_canceled() else \
						new(init[0], name)
				elif init[0].has_method(&"wait"):
					return _FROM_METHOD_NAME_CLASS.create(
						init[0],
						&"wait",
						name)
				elif init[0].has_signal(&"completed"):
					return _FROM_SIGNAL_NAME_CLASS.create(
						init[0],
						&"completed",
						name)
			1 when init[0] is Callable:
				return _FROM_METHOD_CLASS.create(init[0], name)
			1 when init[0] is Signal:
				return _FROM_SIGNAL_CLASS.create(init[0], name)
			1:
				return _COMPLETED_CLASS.create(init[0], name)
	if init is Object:
		if init is Awaitable:
			return \
				_CANCELED_CLASS.create(name) \
				if init.is_canceled() else \
				new(init, name)
		elif init.has_method(&"wait"):
			return _FROM_METHOD_NAME_CLASS.create(init, &"wait", name)
		elif init.has_signal(&"completed"):
			return _FROM_SIGNAL_NAME_CLASS.create(init, &"completed", name)
	if init is Callable:
		return _FROM_METHOD_CLASS.create(init, name)
	if init is Signal:
		return _FROM_SIGNAL_CLASS.create(init, name)
	return _COMPLETED_CLASS.create(init, name)

func finalize() -> void:
	if _task is CustomTask:
		_task.temporary_release(self)
	_task = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _COMPLETED_CLASS := preload("uid://cxtfk6753t3x5")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")
const _FROM_METHOD_NAME_CLASS := preload("uid://dy8sicj8lrg8y")
const _FROM_METHOD_CLASS := preload("uid://dxdjtx2f1e176")
const _FROM_BOUND_METHOD_NAME_CLASS := preload("uid://0qyj5d0p0hoo")
const _FROM_BOUND_METHOD_CLASS := preload("uid://cw5fbusiiwqmv")
const _FROM_SIGNAL_NAME_CLASS := preload("uid://bcixwy06v8s6n")
const _FROM_SIGNAL_CLASS := preload("uid://dcuyxx4r6qafe")
const _FROM_FILTERED_SIGNAL_NAME_CLASS := preload("uid://bvyq3bu45benl")
const _FROM_FILTERED_SIGNAL_CLASS := preload("uid://coguo2lmcq4vl")

var _task: Awaitable

func _init(task: Awaitable, name: StringName) -> void:
	super(name)

	_task = task
	_fork()

func _fork() -> void:
	var result: Variant = \
		await _task.temporary_wait(self) \
		if _task is CustomTask else \
		await _task.wait(get_cascade_cancel())
	if is_pending():
		if _task is Task:
			match _task.get_state():
				STATE_COMPLETED:
					release_complete(result)
				STATE_CANCELED:
					release_cancel()
				_:
					if not _task is CustomTask or not _task.is_pending():
						_AUTOLOAD_CLASS.print_error(&"UNKNOWN_STATE_RETURNED_BY_ANTECEDENT", _task)
						breakpoint
					release_cancel()
		else:
			release_complete(result)
