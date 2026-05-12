class_name Cancel_Timeout extends Test

class Callsite:

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.timeout(0.1)
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_delay(0.1)
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_0タイムアウト() -> void:
	var cancel := Cancel.timeout(0.0)
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())
