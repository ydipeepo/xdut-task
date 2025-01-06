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

class_name XDUT_LoadTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	resource_path: String,
	resource_type: StringName,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"LoadTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	return new(
		resource_path,
		resource_type,
		cancel,
		name)

func cleanup() -> void:
	if _worker != null:
		_worker.loaded.disconnect(release_complete)
		_worker.failed.disconnect(release_cancel)
		_worker = null
	super()

#-------------------------------------------------------------------------------

var _worker: XDUT_LoadTaskWorker

func _init(
	resource_path: String,
	resource_type: StringName,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)

	var canonical := get_canonical()
	if canonical == null:
		release_cancel()
		return

	_worker = XDUT_LoadTaskWorker.create(
		canonical,
		resource_path,
		resource_type)
	if _worker == null:
		release_cancel()
		return

	_worker.loaded.connect(release_complete)
	_worker.failed.connect(release_cancel)
