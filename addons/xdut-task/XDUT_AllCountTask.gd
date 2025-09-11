class_name XDUT_AllCountTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	init_array: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"AllCountTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if init_array.is_empty():
		return XDUT_CompletedTask.new(0, name)
	return new(init_array, cancel, name)

static func create_with_extract_cancel(
	init_array_with_cancel: Array,
	skip_pre_validation: bool,
	name := &"AllCountTask") -> Task:

	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return create(init_array_with_cancel, cancel, skip_pre_validation, name)

#-------------------------------------------------------------------------------

var _remaining: int
var _count: int

func _init(init_array: Array, cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	_remaining = init_array.size()
	for init_index: int in init_array.size():
		var init := XDUT_FromTask.create(
			init_array[init_index],
			cancel,
			true)
		_perform(init, init_index, cancel)

func _perform(init: Awaitable, init_index: int, cancel: Cancel) -> void:
	await init.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match init.get_state():
				STATE_COMPLETED:
					_remaining -= 1
					_count += 1
					if _remaining == 0:
						release_complete(_count)
				STATE_CANCELED:
					_remaining -= 1
					if _remaining == 0:
						release_complete(_count)
				_:
					assert(false, internal_get_task_canonical()
						.translate(&"ERROR_BAD_STATE_WITH_ORDINAL")
						.format([init, init_index]))
