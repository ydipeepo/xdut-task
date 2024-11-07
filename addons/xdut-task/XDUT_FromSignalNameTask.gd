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

class_name XDUT_FromSignalNameTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const MAX_SIGNAL_ARGC := 5

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	object: Object,
	signal_name: StringName,
	signal_argc: int,
	cancel: Cancel,
	skip_pre_validation := false) -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new()
		else:
			cancel = null
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return XDUT_CanceledTask.new()
	if not object.has_signal(signal_name):
		push_error("Invalid signal name: ", signal_name)
		return XDUT_CanceledTask.new()
	if signal_argc < 0 and MAX_SIGNAL_ARGC < signal_argc:
		push_error("Invalid signal argument count: ", signal_argc)
		return XDUT_CanceledTask.new()

	return new(
		object,
		signal_name,
		signal_argc,
		cancel)

func release_cancel_with_cleanup() -> void:
	if is_instance_valid(_object):
		match _signal_argc:
			0: _object.disconnect(_signal_name, _on_completed_0)
			1: _object.disconnect(_signal_name, _on_completed_1)
			2: _object.disconnect(_signal_name, _on_completed_2)
			3: _object.disconnect(_signal_name, _on_completed_3)
			4: _object.disconnect(_signal_name, _on_completed_4)
			5: _object.disconnect(_signal_name, _on_completed_5)
	super()

#-------------------------------------------------------------------------------

var _object: Object
var _signal_name: StringName
var _signal_argc: int

func _init(object: Object, signal_name: StringName, signal_argc: int, cancel: Cancel) -> void:
	super(cancel, false)
	_object = object
	_signal_name = signal_name
	_signal_argc = signal_argc
	match _signal_argc:
		0: _object.connect(_signal_name, _on_completed_0)
		1: _object.connect(_signal_name, _on_completed_1)
		2: _object.connect(_signal_name, _on_completed_2)
		3: _object.connect(_signal_name, _on_completed_3)
		4: _object.connect(_signal_name, _on_completed_4)
		5: _object.connect(_signal_name, _on_completed_5)

func _on_completed_0() -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_0)
	if is_pending:
		release_complete([])

func _on_completed_1(arg1: Variant) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_1)
	if is_pending:
		release_complete([arg1])

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_2)
	if is_pending:
		release_complete([arg1, arg2])

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_3)
	if is_pending:
		release_complete([arg1, arg2, arg3])

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_4)
	if is_pending:
		release_complete([arg1, arg2, arg3, arg4])

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if is_instance_valid(_object):
		_object.disconnect(_signal_name, _on_completed_5)
	if is_pending:
		release_complete([arg1, arg2, arg3, arg4, arg5])

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
	return str + "<FromSignalNameTask#%d>" % get_instance_id()
