class_name XDUT_TaskBase extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func get_canonical() -> Node:
	if not is_instance_valid(_canonical):
		_canonical = Engine \
			.get_main_loop() \
			.root \
			.get_node("/root/XDUT_TaskCanonical")
	return _canonical

func get_state() -> int:
	return _state

func wait(cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if is_instance_valid(cancel) and not cancel.requested.is_connected(release_cancel):
			await _wait_with_exotic_cancel(cancel)
		else:
			await _wait()
	return _result

func release_complete(result: Variant = null) -> void:
	match _state:
		STATE_PENDING:
			_result = result
			_state = STATE_COMPLETED
			cleanup()
		STATE_PENDING_WITH_WAITERS:
			_result = result
			_state = STATE_COMPLETED
			cleanup()
			_release.emit()

func release_cancel() -> void:
	match _state:
		STATE_PENDING:
			_state = STATE_CANCELED
			cleanup()
		STATE_PENDING_WITH_WAITERS:
			_state = STATE_CANCELED
			cleanup()
			_release.emit()

func cleanup() -> void:
	if _cancel != null:
		if _cancel.requested.is_connected(release_cancel):
			_cancel.requested.disconnect(release_cancel)
		_cancel = null

func is_indefinitely_pending() -> bool:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return false

func error_bad_state_at(input: Variant, input_index: int) -> void:
	push_error("Bad state: inputs[%d] (%s)" % [
		input_index,
		input.to_string(),
	])
	breakpoint # BUG

func error_bad_state(input: Variant) -> void:
	push_error("Bad state: input (%s)" % input.to_string())
	breakpoint # BUG

#-------------------------------------------------------------------------------

signal _release

static var _canonical: Node

var _name: StringName
var _state: int = STATE_PENDING
var _result: Variant
var _cancel: Cancel

func _wait() -> void:
	assert(_state == STATE_PENDING_WITH_WAITERS)
	await _release

func _wait_with_exotic_cancel(cancel: Cancel) -> void:
	assert(_state == STATE_PENDING_WITH_WAITERS)
	if cancel.is_requested:
		release_cancel()
	else:
		cancel.requested.connect(release_cancel)
		await _release
		cancel.requested.disconnect(release_cancel)

func _init(
	cancel: Cancel,
	monitor_deadlock: bool,
	name: StringName) -> void:

	_name = name

	if monitor_deadlock:
		var canonical := get_canonical()
		if canonical == null:
			release_cancel()
			return
		canonical.monitor_deadlock(self)

	if cancel != null:
		assert(not cancel.is_requested)
		_cancel = cancel
		_cancel.requested.connect(release_cancel)

func _to_string() -> String:
	var str: String
	match get_state():
		STATE_PENDING:
			str = "(pending)"
		STATE_PENDING_WITH_WAITERS:
			str = "(pending_with_waiters)"
		STATE_CANCELED:
			str = "(canceled)"
		STATE_COMPLETED:
			str = "(completed)"
		_:
			assert(false)
	return "%s<%s#%d>" % [str, _name, get_instance_id()]
