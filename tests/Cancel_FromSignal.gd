class_name Cancel_FromSignal extends Test

class Callsite:

	signal completed

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal(callsite.completed)
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_空() -> void:
	var cancel := Cancel.from_signal(Signal())
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())
