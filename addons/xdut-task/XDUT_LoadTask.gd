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

func release_cancel_with_cleanup() -> void:
	var canonical := get_canonical()
	if canonical != null:
		canonical.process_frame.disconnect(_on_process)
	super()

#-------------------------------------------------------------------------------

var _resource_path: String

func _init(
	resource_path: String,
	resource_type: StringName,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)

	var result := ResourceLoader.load_threaded_request(
		resource_path,
		resource_type,
		true,
		ResourceLoader.CACHE_MODE_IGNORE)

	if result != OK:
		release_cancel()
		return

	var canonical := get_canonical()
	if canonical == null:
		release_cancel()
		return

	_resource_path = resource_path
	canonical.process_frame.connect(_on_process)

func _on_process(delta: float) -> void:
	match ResourceLoader.load_threaded_get_status(_resource_path):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Failed to load due to reached invalid resource: ", _resource_path)
			release_cancel_with_cleanup()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("Failed to load due to some error occurred: ", _resource_path)
			release_cancel_with_cleanup()
		ResourceLoader.THREAD_LOAD_LOADED:
			var canonical := get_canonical()
			if canonical != null:
				canonical.process_frame.disconnect(_on_process)
			var resource := ResourceLoader.load_threaded_get(_resource_path)
			if is_pending:
				release_complete(resource)
