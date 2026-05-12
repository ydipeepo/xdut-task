class_name Task_ThenMethodName extends Test

class Callsite:

	func noop() -> void:
		pass

	func noop_return() -> int:
		return 123

	func fork() -> void:
		await _test.wait_defer()

	func fork_return() -> int:
		await _test.wait_defer()
		return 123

	var _test: Test

	func _init(test: Test) -> void:
		_test = test

func 継続_完了したタスクから() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait()
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait(Cancel.canceled())
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait(Cancel.deferred())
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait()
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait(Cancel.canceled())
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_completed())

func 継続_完了するタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait(Cancel.deferred())
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_キャンセルしたタスクから() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait()
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルしたタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait(Cancel.canceled())
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルしたタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait(Cancel.deferred())
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルするタスクから() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait()
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルするタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait(Cancel.canceled())
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_canceled())

func 継続_キャンセルするタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait(Cancel.deferred())
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.canceled()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())
