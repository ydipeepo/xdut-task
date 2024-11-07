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

class_name XDUT_AnyTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_inits: Array,
	cancel: Cancel,
	skip_pre_validation := false) -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new()
		else:
			cancel = null
	if from_inits.is_empty():
		return XDUT_CanceledTask.new()

	return new(
		from_inits,
		cancel)

#-------------------------------------------------------------------------------

var _remaining: int

func _init(
	from_inits: Array,
	cancel: Cancel) -> void:

	super(cancel, false)
	var from_inits_size := from_inits.size()
	_remaining = from_inits_size
	for task_index: int in from_inits_size:
		var task := XDUT_FromTask.create(
			from_inits[task_index],
			cancel,
			true)
		_perform(
			task,
			task_index,
			cancel)

func _perform(
	task: Variant,
	task_index: int,
	cancel: Cancel) -> void:

	var result: Variant = await task.wait(cancel)
	if is_pending:
		match task.get_state():
			STATE_COMPLETED:
				release_complete(result)
			STATE_CANCELED:
				_remaining -= 1
				if _remaining == 0:
					release_cancel()
			_:
				error_bad_state_at(task, task_index)

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
	return str + "<AnyTask#%d>" % get_instance_id()
