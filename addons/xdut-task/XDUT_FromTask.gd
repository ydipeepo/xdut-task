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

class_name XDUT_FromTask extends XDUT_TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	from_init: Variant,
	cancel: Cancel,
	skip_pre_validation: bool,
	name := &"FromTask") -> Task:

	if not skip_pre_validation:
		if is_instance_valid(cancel):
			if cancel.is_requested:
				return XDUT_CanceledTask.new(name)
		else:
			cancel = null

	if from_init is Array:
		match from_init.size():
			3:
				if from_init[0] is Object and (from_init[1] is String or from_init[1] is StringName):
					if from_init[0].has_method(from_init[1]):
						if from_init[2] is Array:
							return XDUT_FromBoundMethodNameTask.create(
								from_init[0],
								from_init[1],
								from_init[2],
								cancel,
								true,
								name)
					if from_init[0].has_signal(from_init[1]):
						if from_init[2] is int:
							return XDUT_FromSignalNameTask.create(
								from_init[0],
								from_init[1],
								from_init[2],
								cancel,
								true,
								name)
						if from_init[2] is Array:
							return XDUT_FromConditionalSignalNameTask.create_conditional(
								from_init[0],
								from_init[1],
								from_init[2],
								cancel,
								true,
								name)
			2:
				if from_init[0] is Object and (from_init[1] is String or from_init[1] is StringName):
					if from_init[0].has_method(from_init[1]):
						return XDUT_FromMethodNameTask.create(
							from_init[0],
							from_init[1],
							cancel,
							true,
							name)
					if from_init[0].has_signal(from_init[1]):
						return XDUT_FromSignalNameTask.create(
							from_init[0],
							from_init[1],
							0,
							cancel,
							true,
							name)
				if from_init[0] is Callable:
					if from_init[1] is Array:
						return XDUT_FromBoundMethodTask.create(
							from_init[0],
							from_init[1],
							cancel,
							true,
							name)
				if from_init[0] is Signal:
					if from_init[1] is int:
						return XDUT_FromSignalTask.create(
							from_init[0],
							from_init[1],
							cancel,
							true,
							name)
					if from_init[1] is Array:
						return XDUT_FromConditionalSignalTask.create_conditional(
							from_init[0],
							from_init[1],
							cancel,
							true,
							name)
			1:
				if from_init[0] is Awaitable:
					return new(
						from_init[0],
						cancel,
						name)
				if from_init[0] is Object:
					if from_init[0].has_method(&"wait"):
						return XDUT_FromMethodNameTask.create(
							from_init[0],
							&"wait",
							cancel,
							true,
							name)
					if from_init[0].has_signal(&"completed"):
						return XDUT_FromSignalNameTask.create(
							from_init[0],
							&"completed",
							0,
							cancel,
							true,
							name)
				if from_init[0] is Callable:
					return XDUT_FromMethodTask.create(
						from_init[0],
						cancel,
						true,
						name)
				if from_init[0] is Signal:
					return XDUT_FromSignalTask.create(
						from_init[0],
						0,
						cancel,
						true,
						name)
	if from_init is Awaitable:
		return new(
			from_init,
			cancel,
			name)
	if from_init is Object:
		if from_init.has_method(&"wait"):
			return XDUT_FromMethodNameTask.create(
				from_init,
				&"wait",
				cancel,
				true,
				name)
		if from_init.has_signal(&"completed"):
			return XDUT_FromSignalNameTask.create(
				from_init,
				&"completed",
				0,
				cancel,
				true,
				name)
	if from_init is Callable:
		return XDUT_FromMethodTask.create(
			from_init,
			cancel,
			true,
			name)
	if from_init is Signal:
		return XDUT_FromSignalTask.create(
			from_init,
			0,
			cancel,
			true,
			name)
	return XDUT_CompletedTask.new(
		from_init,
		name)

#-------------------------------------------------------------------------------

func _init(
	source_awaitable: Awaitable,
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, false, name)

	_perform(source_awaitable, cancel)

func _perform(
	source_awaitable: Awaitable,
	cancel: Cancel) -> void:

	var result: Variant = await source_awaitable.wait(cancel)
	if is_pending:
		match source_awaitable.get_state():
			STATE_COMPLETED:
				release_complete(result)
			STATE_CANCELED:
				release_cancel()
