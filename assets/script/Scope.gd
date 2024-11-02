class_name Scope

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const RETURN := 123
const ARG1 := 123
const ARG2 := "abc"
const ARG3 := true
const ARG4 := null
const ARG5 := 0.5

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

@warning_ignore("unused_signal")
signal signal_0
@warning_ignore("unused_signal")
signal signal_1(arg1: Variant)
@warning_ignore("unused_signal")
signal signal_2(arg1: Variant, arg2: Variant)
@warning_ignore("unused_signal")
signal signal_3(arg1: Variant, arg2: Variant, arg3: Variant)
@warning_ignore("unused_signal")
signal signal_4(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant)
@warning_ignore("unused_signal")
signal signal_5(arg1: Variant, arg2: Variant, arg3: Variant, arg4: Variant, arg5: Variant)

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func emit_signal_0() -> void:
	emit_signal(&"signal_0")

func emit_signal_1(arg1: Variant = ARG1) -> void:
	emit_signal(&"signal_1", arg1)

func emit_signal_2(arg1: Variant = ARG1, arg2: Variant = ARG2) -> void:
	emit_signal(&"signal_2", arg1, arg2)

func emit_signal_3(arg1: Variant = ARG1, arg2: Variant = ARG2, arg3: Variant = ARG3) -> void:
	emit_signal(&"signal_3", arg1, arg2, arg3)

func emit_signal_4(arg1: Variant = ARG1, arg2: Variant = ARG2, arg3: Variant = ARG3, arg4: Variant = ARG4) -> void:
	emit_signal(&"signal_4", arg1, arg2, arg3, arg4)

func emit_signal_5(arg1: Variant = ARG1, arg2: Variant = ARG2, arg3: Variant = ARG3, arg4: Variant = ARG4, arg5: Variant = ARG5) -> void:
	emit_signal(&"signal_5", arg1, arg2, arg3, arg4, arg5)

func from_immediate() -> void:
	pass

func from_immediate_return() -> int:
	return RETURN

func from_deferred() -> void:
	emit_signal.call_deferred("_defer")
	await _defer

func from_deferred_return() -> int:
	emit_signal.call_deferred("_defer")
	await _defer
	return RETURN

func from_callback_immediate(set_: Callable, _cancel: Callable) -> void:
	set_.call()

func from_callback_immediate_return(set_: Callable, _cancel: Callable) -> void:
	set_.call(RETURN)

func from_callback_immediate_cancel(_set: Callable, cancel: Callable) -> void:
	cancel.call()

func from_callback_deferred(set_: Callable, _cancel: Callable) -> void:
	set_.call_deferred()

func from_callback_deferred_return(set_: Callable, _cancel: Callable) -> void:
	set_.call_deferred(RETURN)

func from_callback_deferred_cancel(_set: Callable, cancel: Callable) -> void:
	cancel.call_deferred()

func then_immediate(_input: Variant) -> void:
	pass

func then_immediate_return(_input: Variant) -> int:
	return RETURN

func then_deferred(_input: Variant) -> void:
	emit_signal.call_deferred("_defer")
	await _defer

func then_deferred_return(_input: Variant) -> int:
	emit_signal.call_deferred("_defer")
	await _defer
	return RETURN

func then_callback_immediate(_1: Variant, set_: Callable, _cancel: Callable) -> void:
	set_.call()

func then_callback_immediate_return(_1: Variant, set_: Callable, _cancel: Callable) -> void:
	set_.call(RETURN)

func then_callback_immediate_cancel(_1: Variant, _set: Callable, cancel: Callable) -> void:
	cancel.call()

func then_callback_deferred(_1: Variant, set_: Callable, _cancel: Callable) -> void:
	set_.call_deferred()

func then_callback_deferred_return(_1: Variant, set_: Callable, _cancel: Callable) -> void:
	set_.call_deferred(RETURN)

func then_callback_deferred_cancel(_1: Variant, _set: Callable, cancel: Callable) -> void:
	cancel.call_deferred()

#-------------------------------------------------------------------------------

signal _defer
