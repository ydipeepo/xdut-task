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
#	CONSTANTS
#-------------------------------------------------------------------------------

const ACCEPTIBLE_METHOD_ARGC: Array[int] = [2, 3, 4]

#---------------------------------------------------------------------------------------------------
#	METHODS
#---------------------------------------------------------------------------------------------------

func is_orphaned() -> bool:
	return is_pending and not _method.is_valid()

#-------------------------------------------------------------------------------

var _method: Callable

func _init(prev: Awaitable, method: Callable, cancel: Cancel) -> void:
	assert(is_instance_valid(prev))
	assert(method.is_valid())
	assert(method.get_argument_count() in ACCEPTIBLE_METHOD_ARGC)

	super(cancel, true)
	_method = method
	_perform(prev, cancel)

func _perform(prev: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await prev.wait(cancel)
	if is_pending:
		match prev.get_state():
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
				error_bad_state(prev)

func _set_core(result: Variant = null) -> void:
	if is_pending:
		if _method.is_valid():
			release_complete(result)
		else:
			release_cancel()

func _cancel_core() -> void:
	if is_pending:
		release_cancel()
