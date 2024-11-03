#-------------------------------------------------------------------------------
#
#
#	Copyright 2022-2024 Ydi (@ydipeepo.bsky.social)
#
#
#	Permission is hereby granted, free of charge, to any person obtaining
#	a copy of this software and associated documentation files (the "Software"),
#	to deal in the Software without restriction, including without limitation
#	the rights to use, copy, modify, merge, publish, distribute, sublicense,
#	and/or sell copies of the Software, and to permit persons to whom
#	the Software is furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#	OTHER DEALINGS IN THE SOFTWARE.
#
#
#-------------------------------------------------------------------------------

class_name XDUT_TaskBase extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func get_canonical() -> Node:
	if not is_instance_valid(_canonical):
		var main_loop := Engine.get_main_loop()
		_canonical = main_loop.root.get_node("/root/XDUT_TaskCanonical")
		assert(_canonical != null)
	return _canonical

func get_state() -> int:
	return _state

func wait(cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if cancel != null:
			await _wait_with_exotic_cancel(cancel)
		else:
			await _wait()
	return _result

func release_complete(result: Variant = null) -> void:
	match _state:
		STATE_PENDING:
			if _cancel != null:
				_cancel.requested.disconnect(on_canceled)
				_cancel = null
			_result = result
			_state = STATE_COMPLETED
		STATE_PENDING_WITH_WAITERS:
			if _cancel != null:
				_cancel.requested.disconnect(on_canceled)
				_cancel = null
			_result = result
			_state = STATE_COMPLETED
			_release.emit()

func release_cancel() -> void:
	match _state:
		STATE_PENDING:
			if _cancel != null:
				_cancel.requested.disconnect(on_canceled)
				_cancel = null
			_state = STATE_CANCELED
		STATE_PENDING_WITH_WAITERS:
			if _cancel != null:
				_cancel.requested.disconnect(on_canceled)
				_cancel = null
			_state = STATE_CANCELED
			_release.emit()

func is_orphaned() -> bool:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return false

func on_orphaned() -> void:
	release_cancel()

func on_canceled() -> void:
	release_cancel()

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

func _init(cancel: Cancel, monitor_deadlock: bool) -> void:
	if cancel != null:
		assert(not cancel.is_requested)
		_cancel = cancel
		_cancel.requested.connect(on_canceled)

	if monitor_deadlock:
		get_canonical().monitor_deadlock(self)
