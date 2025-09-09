class_name XDUT_RaceTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	init_array: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"RaceTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if init_array.is_empty():
		push_warning(internal_task_get_canonical()
			.translate(&"WARNING_BAD_INPUTS"))
		return XDUT_NeverTask.create(cancel, true, name)
	return new(init_array, cancel, name)

static func create_with_extract_cancel(
	init_array_with_cancel: Array,
	skip_pre_validation: bool,
	name := &"RaceTask") -> Task:

	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return create(init_array_with_cancel, cancel, skip_pre_validation, name)

func cleanup() -> void:
	for init_index: int in _init_array.size():
		var init: Awaitable = _init_array[init_index]
		_init_array[init_index] = null
		if init is TaskBase:
			init.release(self)
	super()

#-------------------------------------------------------------------------------

var _init_array: Array[Awaitable]

func _init(init_array: Array, cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	_init_array.resize(init_array.size())
	for init_index: int in init_array.size():
		_init_array[init_index] = XDUT_FromTask.create(
			init_array[init_index],
			cancel,
			true)
	for init_index: int in init_array.size():
		var init := _init_array[init_index]
		_perform(init, init_index, cancel)

func _perform(init: Awaitable, init_index: int, cancel: Cancel) -> void:
	var result: Variant
	if init is TaskBase:
		result = await init.wait_temporary(self, cancel)
	elif init is Awaitable: # 必要
		result = await init.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match init.get_state():
				STATE_COMPLETED:
					release_complete(XDUT_CompletedTask.new(result))
				STATE_CANCELED:
					release_complete(XDUT_CanceledTask.new())
				_:
					assert(false, internal_task_get_canonical()
						.translate(&"ERROR_BAD_STATE_WITH_ORDINAL")
						.format([init, init_index]))
