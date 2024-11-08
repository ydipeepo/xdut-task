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

class_name XDUT_ThenBoundMethodNameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"ThenBoundMethodNameTask") -> Task:

	if not skip_pre_validation:
		if not is_instance_valid(source_awaitable) or source_awaitable.is_canceled:
			return XDUT_CanceledTask.new(name)
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if method_args.is_empty():
		return XDUT_ThenMethodNameTask.create(
			source_awaitable,
			object,
			method_name,
			cancel,
			true,
			name)

	if not is_instance_valid(object):
		push_error("Invalid object.")
		return XDUT_CanceledTask.new(name)
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return XDUT_CanceledTask.new(name)
	var method_argc := object.get_method_argument_count(method_name)
	match method_argc - method_args.size():
		0, 1, 2:
			pass
		_:
			push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
			return XDUT_CanceledTask.new(name)

	return new(
		source_awaitable,
		object,
		method_name,
		method_argc,
		method_args,
		cancel,
		name)

#-------------------------------------------------------------------------------

var _object: Object

func _init(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)
	_object = object
	_perform(source_awaitable, method_name, method_argc, method_args, cancel)

func _perform(
	source_awaitable: Awaitable,
	method_name: StringName,
	method_argc: int,
	method_args: Array,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
			STATE_COMPLETED:
				if is_instance_valid(_object):
					match method_argc - method_args.size():
						0: result = await _object.callv(method_name, method_args)
						1: result = await _object.callv(method_name, method_args + [result])
						2: result = await _object.callv(method_name, method_args + [result, cancel])
					if is_pending:
						release_complete(result)
				else:
					release_cancel()
			STATE_CANCELED:
				release_cancel()
			_:
				error_bad_state(source_awaitable)
