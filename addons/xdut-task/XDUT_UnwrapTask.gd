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

class_name XDUT_UnwrapTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------

func _init(input: Awaitable, depth: int, cancel: Cancel) -> void:
	assert(is_instance_valid(input))
	assert(0 < depth)

	super(cancel, false)
	_perform(input, depth, cancel)

func _perform(input: Variant, depth: int, cancel: Cancel) -> void:
	var result: Variant = await input.wait(cancel)
	while result is Awaitable and depth != 0:
		input = result
		result = await input.wait(cancel)
		depth -= 1
	if is_pending:
		match input.get_state():
			STATE_COMPLETED:
				release_complete(result)
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(input)
