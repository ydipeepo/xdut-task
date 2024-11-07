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

class_name XDUT_ThenMethodTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel,
	skip_pre_validation := false) -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new()
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new()
		else:
			cancel = null
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return XDUT_CanceledTask.new()
	if not method.get_argument_count() in _VALID_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return XDUT_CanceledTask.new()

	return new(
		source_awaitable,
		method,
		cancel)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

const _VALID_METHOD_ARGC: Array[int] = [0, 1, 2]

var _method: Callable

func _init(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel) -> void:

	super(cancel, true)
	_method = method
	_perform(source_awaitable, cancel)

func _perform(
	source_awaitable: Awaitable,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
			STATE_COMPLETED:
				if _method.is_valid():
					match _method.get_argument_count():
						0: result = await _method.call()
						1: result = await _method.call(result)
						2: result = await _method.call(result, cancel)
					if is_pending:
						if _method.is_valid():
							release_complete(result)
						else:
							release_cancel()
				else:
					release_cancel()
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source_awaitable)

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
	return str + "<ThenMethodTask#%d>" % get_instance_id()
