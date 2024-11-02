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

class_name XDUT_FromMethodNameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const ACCEPTIBLE_METHOD_ARGC: Array[int] = [0, 1]

#-------------------------------------------------------------------------------

var _object: Object
var _method_name: StringName

func _init(object: Object, method_name: StringName, cancel: Cancel) -> void:
	assert(is_instance_valid(object) and object.has_method(method_name))
	assert(object.get_method_argument_count(method_name) in ACCEPTIBLE_METHOD_ARGC)

	super(cancel, false)
	_object = object
	_method_name = method_name
	_perform(cancel)

func _perform(cancel: Cancel) -> void:
	var result: Variant
	match _object.get_method_argument_count(_method_name):
		0: result = await _object.call(_method_name)
		1: result = await _object.call(_method_name, cancel)
	if is_pending:
		release_complete(result)
