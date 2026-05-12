class_name Cancel_WithOperators extends Test

class Callsite:

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var opers := Cancel.with_operators()
	if not is_not_empty(opers):
		return
	are_equal(2, opers.size())
	opers[0].requested.connect(callsite.on_requested)
	is_false(opers[0].is_requested())
	are_equal(0, callsite.requested_count)
	opers[1].call()
	is_true(opers[0].is_requested())
	are_equal(1, callsite.requested_count)
