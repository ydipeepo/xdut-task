class_name XDUT_ThenTask extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	then_init: Variant,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenTask") -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if then_init is Array:
		match then_init.size():
			3 when then_init[0] is Object and (then_init[1] is String or then_init[1] is StringName):
				if then_init[0].has_method(then_init[1]):
					if then_init[2] is Array:
						return XDUT_ThenBoundMethodNameTask.create(
							source_awaitable,
							then_init[0],
							then_init[1],
							then_init[2],
							cancel,
							true,
							name)
			2 when then_init[0] is Object and (then_init[1] is String or then_init[1] is StringName):
				if then_init[0].has_method(then_init[1]):
					return XDUT_ThenMethodNameTask.create(
						source_awaitable,
						then_init[0],
						then_init[1],
						cancel,
						true,
						name)
			2 when then_init[0] is Callable:
				if then_init[1] is Array:
					return XDUT_ThenBoundMethodTask.create(
						source_awaitable,
						then_init[0],
						then_init[1],
						cancel,
						true,
						name)
			1 when then_init[0] is Awaitable:
				return new(
					source_awaitable,
					then_init[0],
					cancel,
					name)
			1 when then_init[0] is Object:
				if then_init[0].has_method(&"wait"):
					return XDUT_ThenMethodNameTask.create(
						source_awaitable,
						then_init[0],
						&"wait",
						cancel,
						true,
						name)
			1 when then_init[0] is Callable:
				return XDUT_ThenMethodTask.create(
					source_awaitable,
					then_init[0],
					cancel,
					true,
					name)
	if then_init is Awaitable:
		return new(
			source_awaitable,
			then_init,
			cancel,
			name)
	if then_init is Object:
		if then_init.has_method(&"wait"):
			return XDUT_ThenMethodNameTask.create(
				source_awaitable,
				then_init,
				&"wait",
				cancel,
				true,
				name)
	if then_init is Callable:
		return XDUT_ThenMethodTask.create(
			source_awaitable,
			then_init,
			cancel,
			true,
			name)
	return new(
		source_awaitable,
		then_init,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _then: Variant

func _init(
	source_awaitable: Awaitable,
	then: Variant,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	_then = then
	_perform(source_awaitable, cancel)

func _perform(
	source_awaitable: Awaitable,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		if _then is Awaitable:
			match source_awaitable.get_state():
				STATE_COMPLETED:
					if _then.is_canceled:
						release_cancel()
					else:
						result = await _then.wait(cancel)
						if is_pending:
							if _then.is_canceled:
								release_cancel()
							else:
								release_complete(result)
				STATE_CANCELED:
					release_cancel()
				_:
					error_bad_state(source_awaitable)
		else:
			match source_awaitable.get_state():
				STATE_COMPLETED:
					release_complete(_then)
				STATE_CANCELED:
					release_cancel()
				_:
					error_bad_state(source_awaitable)
