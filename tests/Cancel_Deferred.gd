class_name Cancel_Deferred extends Test

class Callsite:

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.deferred()
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)
