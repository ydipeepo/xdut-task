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

class_name XDUT_FromConditionalSignalTask extends XDUT_FromSignalTask

#--------------------------------------------------------------------------------

var _signal_args: Array

static func _match(a: Variant, b: Variant) -> bool:
	return a is Object and a == SKIP or typeof(a) == typeof(b) and a == b

func _init(signal_: Signal, signal_args: Array, cancel: Cancel) -> void:
	super(signal_, signal_args.size(), cancel)
	_signal_args = signal_args

func _on_completed_1(arg1: Variant) -> void:
	if _match(_signal_args[0], arg1):
		super(arg1)

func _on_completed_2(arg1: Variant, arg2: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2):
		super(arg1, arg2)

func _on_completed_3(arg1: Variant, arg2: Variant, arg3: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3):
		super(arg1, arg2, arg3)

func _on_completed_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3) and _match(_signal_args[3], arg4):
		super(arg1, arg2, arg3, arg4)

func _on_completed_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant) -> void:
	if _match(_signal_args[0], arg1) and _match(_signal_args[1], arg2) and _match(_signal_args[2], arg3) and _match(_signal_args[3], arg4) and _match(_signal_args[4], arg5):
		super(arg1, arg2, arg3, arg4, arg5)
