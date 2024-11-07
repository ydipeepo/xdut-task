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

class_name XDUT_ThenCallbackTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenCallbackTask") -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return XDUT_CanceledTask.new(name)
	if not method.get_argument_count() in _VALID_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return XDUT_CanceledTask.new(name)

	return new(
		source_awaitable,
		method,
		cancel,
		name)

func is_indefinitely_pending() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

const _VALID_METHOD_ARGC: Array[int] = [2, 3, 4]

var _method: Callable

func _init(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, true, name)
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
						2: await _method.call(result, _set_core)
						3: await _method.call(result, _set_core, _cancel_core)
						4: await _method.call(result, _set_core, _cancel_core, cancel)
				else:
					release_cancel()
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source_awaitable)

func _set_core(result: Variant = null) -> void:
	if is_pending:
		if _method.is_valid():
			release_complete(result)
		else:
			release_cancel()

func _cancel_core() -> void:
	if is_pending:
		release_cancel()
