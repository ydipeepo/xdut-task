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

class_name XDUT_DelayTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"DelayTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if timeout < _MIN_TIMEOUT:
		push_warning("Invalid timeout.")
		return XDUT_CompletedTask.new(null, name)
	if timeout == _MIN_TIMEOUT:
		return XDUT_CompletedTask.new(null, name)
	return new(
		timeout,
		ignore_pause,
		ignore_time_scale,
		cancel,
		name)

func release_cancel_with_cleanup() -> void:
	if _timer != null:
		_timer.timeout.disconnect(_on_timeout)
		_timer = null
	super()

#-------------------------------------------------------------------------------

const _MIN_TIMEOUT := 0.0

var _timer: SceneTreeTimer

func _init(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	var canonical := get_canonical()
	if canonical != null:
		_timer = canonical.create_timer(
			timeout,
			ignore_pause,
			ignore_time_scale)
		_timer.timeout.connect(_on_timeout)
	else:
		release_cancel()

func _on_timeout() -> void:
	if _timer != null:
		_timer.timeout.disconnect(_on_timeout)
		_timer = null
	if is_pending:
		release_complete()
