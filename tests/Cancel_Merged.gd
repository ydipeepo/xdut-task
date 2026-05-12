class_name Cancel_Merged extends Test

class Callsite:

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移_空() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.merged()
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)

func 状態遷移_複合() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.merged(
		Cancel.deferred(),
		Cancel.canceled(),
		Cancel.deferred())
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)

func 状態遷移_即時() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.merged(
		Cancel.canceled(),
		Cancel.canceled(),
		Cancel.canceled())
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(0, callsite.requested_count)

func 状態遷移_遅延() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.merged(
		Cancel.deferred(),
		Cancel.deferred(),
		Cancel.deferred())
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)
