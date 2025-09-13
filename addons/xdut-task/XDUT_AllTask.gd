class_name XDUT_AllTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	init_array: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"AllTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if init_array.is_empty():
		return XDUT_CompletedTask.new([], name)
	return new(init_array, cancel, name)

static func create_with_extract_cancel(
	init_array_with_cancel: Array,
	skip_pre_validation: bool,
	name := &"AllTask") -> Task:

	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return create(init_array_with_cancel, cancel, skip_pre_validation, name)

#-------------------------------------------------------------------------------

var _num_pending: int

func _init(init_array: Array, cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	
	var result_set := []; result_set.resize(init_array.size())
	_num_pending = init_array.size()
	for init_index: int in init_array.size():
		var init := XDUT_FromTask.create(
			init_array[init_index],
			cancel,
			true)
		_perform(init, init_index, cancel, result_set)

func _perform(
	init: Awaitable,
	init_index: int,
	cancel: Cancel,
	result_set: Array) -> void:

	var result: Variant = await init.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match init.get_state():
				STATE_COMPLETED:
					result_set[init_index] = result
					_num_pending -= 1
					if _num_pending == 0:
						release_complete(result_set)
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_INIT")
						.format([init, init_index]))
					breakpoint
