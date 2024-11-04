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
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	depth: int,
	cancel: Cancel,
	skip_pre_validation := false) -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return canceled()
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return canceled()
		else:
			cancel = null
	if depth < 0:
		push_error("Invalid depth.")
		return canceled()
	if depth == 0:
		return source_awaitable
	return new(
		source_awaitable,
		depth,
		cancel)

#-------------------------------------------------------------------------------

func _init(
	source_awaitable: Awaitable,
	depth: int,
	cancel: Cancel) -> void:

	super(cancel, false)
	_perform(source_awaitable, depth, cancel)

func _perform(
	source: Variant,
	depth: int,
	cancel: Cancel) -> void:

	var result: Variant = await source.wait(cancel)
	while result is Awaitable and depth != 0:
		source = result
		result = await source.wait(cancel)
		depth -= 1
	if is_pending:
		match source.get_state():
			STATE_COMPLETED:
				release_complete(result)
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source)
