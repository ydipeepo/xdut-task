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

class_name XDUT_ThenTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------

var _then: Variant

func _init(prev: Awaitable, then: Variant, cancel: Cancel) -> void:
	assert(is_instance_valid(prev))

	super(cancel, false)
	_then = then
	_perform(prev, cancel)

func _perform(prev: Awaitable, cancel: Cancel) -> void:
	var result: Variant = await prev.wait(cancel)
	if is_pending:
		if _then is Awaitable:
			match prev.get_state():
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
					error_bad_state(prev)
		else:
			if is_pending:
				match prev.get_state():
					STATE_COMPLETED:
						release_complete(_then)
					STATE_CANCELED:
						release_cancel()
					_:
						error_bad_state(prev)
