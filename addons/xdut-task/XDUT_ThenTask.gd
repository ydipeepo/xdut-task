class_name XDUT_ThenTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	antecedent: Awaitable,
	init: Variant,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if not is_instance_valid(antecedent) or antecedent.is_canceled:
			return XDUT_CanceledTask.new(name)
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if init is Array:
		match init.size():
			3 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					if init[2] is Array:
						return XDUT_ThenBoundMethodNameTask.create(
							antecedent,
							init[0],
							init[1],
							init[2],
							cancel,
							true,
							name)
			2 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					return XDUT_ThenMethodNameTask.create(
						antecedent,
						init[0],
						init[1],
						cancel,
						true,
						name)
			2 when init[0] is Callable:
				if init[1] is Array:
					return XDUT_ThenBoundMethodTask.create(
						antecedent,
						init[0],
						init[1],
						cancel,
						true,
						name)
			1 when init[0] is Awaitable:
				return new(
					antecedent,
					init[0],
					cancel,
					name)
			1 when init[0] is Object:
				if init[0].has_method(&"wait"):
					return XDUT_ThenMethodNameTask.create(
						antecedent,
						init[0],
						&"wait",
						cancel,
						true,
						name)
			1 when init[0] is Callable:
				return XDUT_ThenMethodTask.create(
					antecedent,
					init[0],
					cancel,
					true,
					name)
	if init is Awaitable:
		return new(
			antecedent,
			init,
			cancel,
			name)
	if init is Object:
		if init.has_method(&"wait"):
			return XDUT_ThenMethodNameTask.create(
				antecedent,
				init,
				&"wait",
				cancel,
				true,
				name)
	if init is Callable:
		return XDUT_ThenMethodTask.create(
			antecedent,
			init,
			cancel,
			true,
			name)
	return new(antecedent, init, cancel, name)

static func create_with_extract_cancel(
	antecedent: Awaitable,
	init_with_cancel: Array,
	skip_pre_validation: bool,
	name := &"ThenTask") -> Task:

	var cancel: Cancel = null
	if not init_with_cancel.is_empty() and init_with_cancel.back() is Cancel:
		cancel = init_with_cancel.pop_back()
	return create(
		antecedent,
		init_with_cancel,
		cancel,
		skip_pre_validation,
		name)

#-------------------------------------------------------------------------------

var _init_: Variant

func _init(
	antecedent: Awaitable,
	init: Variant,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)
	_init_ = init
	_perform(antecedent, cancel)

func _perform(antecedent: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await antecedent.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match antecedent.get_state():
				STATE_COMPLETED:
					if _init_ is Awaitable:
						if not _init_.is_canceled:
							result = await _init_.wait(cancel)
							if not _init_.is_canceled:
								release_complete(result)
							else:
								release_cancel()
						else:
							release_cancel()
					else:
						release_complete(_init_)
				STATE_CANCELED:
					release_cancel()
				_:
					print_debug(internal_get_task_canonical()
						.translate(&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT")
						.format([antecedent]))
					breakpoint
