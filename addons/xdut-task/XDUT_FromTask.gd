class_name XDUT_FromTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	init: Variant,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromTask") -> Task:

	if not is_instance_valid(cancel):
		cancel = null
	if not skip_pre_validation:
		if cancel != null and cancel.is_requested:
			return XDUT_CanceledTask.new(name)
	if init is Array:
		match init.size():
			3 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					if init[2] is Array:
						return XDUT_FromBoundMethodNameTask.create(
							init[0],
							init[1],
							init[2],
							cancel,
							true,
							name)
				if init[0].has_signal(init[1]):
					if init[2] is int:
						return XDUT_FromSignalNameTask.create(
							init[0],
							init[1],
							init[2],
							cancel,
							true,
							name)
					if init[2] is Array:
						return XDUT_FromConditionalSignalNameTask.create_conditional(
							init[0],
							init[1],
							init[2],
							cancel,
							true,
							name)
			2 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_method(init[1]):
					return XDUT_FromMethodNameTask.create(
						init[0],
						init[1],
						cancel,
						true,
						name)
				if init[0].has_signal(init[1]):
					return XDUT_FromSignalNameTask.create(
						init[0],
						init[1],
						0,
						cancel,
						true,
						name)
			2 when init[0] is Callable:
				if init[1] is Array:
					return XDUT_FromBoundMethodTask.create(
						init[0],
						init[1],
						cancel,
						true,
						name)
			2 when init[0] is Signal:
				if init[1] is int:
					return XDUT_FromSignalTask.create(
						init[0],
						init[1],
						cancel,
						true,
						name)
				if init[1] is Array:
					return XDUT_FromConditionalSignalTask.create_conditional(
						init[0],
						init[1],
						cancel,
						true,
						name)
			1 when init[0] is Awaitable:
				return new(
					init[0],
					cancel,
					name)
			1 when init[0] is Object:
				if init[0].has_method(&"wait"):
					return XDUT_FromMethodNameTask.create(
						init[0],
						&"wait",
						cancel,
						true,
						name)
				if init[0].has_signal(&"completed"):
					return XDUT_FromSignalNameTask.create(
						init[0],
						&"completed",
						0,
						cancel,
						true,
						name)
			1 when init[0] is Callable:
				return XDUT_FromMethodTask.create(
					init[0],
					cancel,
					true,
					name)
			1 when init[0] is Signal:
				return XDUT_FromSignalTask.create(
					init[0],
					0,
					cancel,
					true,
					name)
	if init is Awaitable:
		return new(init, cancel, name)
	if init is Object:
		if init.has_method(&"wait"):
			return XDUT_FromMethodNameTask.create(
				init,
				&"wait",
				cancel,
				true,
				name)
		if init.has_signal(&"completed"):
			return XDUT_FromSignalNameTask.create(
				init,
				&"completed",
				0,
				cancel,
				true,
				name)
	if init is Callable:
		return XDUT_FromMethodTask.create(
			init,
			cancel,
			true,
			name)
	if init is Signal:
		return XDUT_FromSignalTask.create(
			init,
			0,
			cancel,
			true,
			name)
	return XDUT_CompletedTask.new(init, name)

static func create_with_extract_cancel(
	init_with_cancel: Array,
	skip_pre_validation: bool,
	name := &"FromTask") -> Task:

	var cancel: Cancel = null
	if not init_with_cancel.is_empty() and init_with_cancel.back() is Cancel:
		cancel = init_with_cancel.pop_back()
	return create(init_with_cancel, cancel, skip_pre_validation, name)

#-------------------------------------------------------------------------------

func _init(source: Awaitable, cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	_perform(source, cancel)

func _perform(source: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await source.wait(cancel)

	match get_state():
		STATE_PENDING, \
		STATE_PENDING_WITH_WAITERS:
			match source.get_state():
				STATE_COMPLETED:
					release_complete(result)
				STATE_CANCELED:
					release_cancel()
