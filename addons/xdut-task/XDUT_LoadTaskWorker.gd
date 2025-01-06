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

class_name XDUT_LoadTaskWorker

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

signal loaded(resource: Variant)

signal failed

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	canonical: Node,
	resource_path: String,
	resource_type: StringName) -> XDUT_LoadTaskWorker:

	assert(canonical != null)

	var result := ResourceLoader.load_threaded_request(
		resource_path,
		resource_type,
		true,
		ResourceLoader.CACHE_MODE_IGNORE)
	if result != OK:
		return null

	return new(canonical, resource_path)

#-------------------------------------------------------------------------------

var _canonical: Node
var _resource_path: String

func _init(
	canonical: Node,
	resource_path: String) -> void:

	reference()

	_resource_path = resource_path
	_canonical = canonical
	_canonical.process_frame.connect(_on_process)

func _on_process(delta: float) -> void:
	match ResourceLoader.load_threaded_get_status(_resource_path):

		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_canonical.process_frame.disconnect(_on_process)
			printerr("Failed to load due to reached invalid resource: ", _resource_path)
			failed.emit()
			unreference()

		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass

		ResourceLoader.THREAD_LOAD_FAILED:
			_canonical.process_frame.disconnect(_on_process)
			printerr("Failed to load due to some error occurred: ", _resource_path)
			failed.emit()
			unreference()

		ResourceLoader.THREAD_LOAD_LOADED:
			_canonical.process_frame.disconnect(_on_process)
			var resource := ResourceLoader.load_threaded_get(_resource_path)
			loaded.emit(resource)
			unreference()
