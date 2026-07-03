class_name Task_ThenBoundMethodName extends Test

class Callsite:

	func noop() -> void:
		pass

	func noop_return() -> int:
		return 123

	func noop_params(a: int, b: int) -> void:
		_test.are_equal(a, 45)
		_test.are_equal(b, 78)

	func noop_params_return(a: int, b: int) -> int:
		_test.are_equal(a, 45)
		_test.are_equal(b, 78)
		return a + b

	func fork() -> void:
		await _test.wait_defer()

	func fork_return() -> int:
		await _test.wait_defer()
		return 123

	func fork_params(a: int, b: int) -> void:
		_test.are_equal(a, 45)
		_test.are_equal(b, 78)
		await _test.wait_defer()

	func fork_params_return(a: int, b: int) -> int:
		_test.are_equal(a, 45)
		_test.are_equal(b, 78)
		await _test.wait_defer()
		return a + b

	var _test: Test

	func _init(test: Test) -> void:
		_test = test

func 継続_完了したタスクから() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	are_equal(123, await task2.wait())
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	is_null(await task2.wait(Cancel.canceled()))
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_キャンセルされたタスクから() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_null(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait())
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_null(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var opers := Task.with_operators()
	if not is_not_null(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"")
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
	var task2 := task1.then_bound_method_name(callsite, &"")
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
	var task2 := task1.then_bound_method_name(callsite, &"")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"", 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"", 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"", 45, 78)
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
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED")
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
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED")
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
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

#func 状態遷移_名前指定あり_不足した引数束縛() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method())
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait())
#	is_true(task2.is_canceled())

#func 状態遷移_名前指定あり_不足した引数束縛_キャンセルあり_即時() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method())
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.canceled()))
#	is_true(task2.is_canceled())

#func 状態遷移_名前指定あり_不足した引数束縛_キャンセルあり_遅延() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method())
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.deferred()))
#	is_true(task2.is_canceled())

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
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
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
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
		var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.noop.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait())
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait())
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_return.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait())
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
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
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait())
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.canceled()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait())
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task2.wait(Cancel.canceled()))
		is_true(task2.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task1 := Task.completed()
		if not is_not_null(task1):
			return
		var task2 := task1.then_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task2.wait(Cancel.deferred()))
		is_true(task2.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())
