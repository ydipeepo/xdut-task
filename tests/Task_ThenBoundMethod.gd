class_name Task_ThenBoundMethod extends Test

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
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	are_equal(123, await task2.wait())
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	is_null(await task2.wait(Cancel.canceled()))
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_completed())

func 継続_完了するタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_キャンセルされたタスクから() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait())
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait(Cancel.canceled()))
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		marks[0] = true
		return a * b, 45, 78)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	is_null(await task2.wait(Cancel.deferred()))
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 状態遷移_空() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_空_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_空_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_空_引数束縛() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_空_引数束縛_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_空_引数束縛_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(Callable(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_ラムダ_超過した引数束縛() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_ラムダ_超過した引数束縛_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_ラムダ_超過した引数束縛_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

#func 状態遷移_ラムダ_不足した引数束縛() -> void:
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	@warning_ignore("unused_parameter")
#	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
#		pass)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait())
#	is_true(task2.is_canceled())

#func 状態遷移_ラムダ_不足した引数束縛_キャンセルあり_即時() -> void:
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	@warning_ignore("unused_parameter")
#	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
#		pass)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.canceled()))
#	is_true(task2.is_canceled())

#func 状態遷移_ラムダ_不足した引数束縛_キャンセルあり_遅延() -> void:
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	@warning_ignore("unused_parameter")
#	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
#		pass)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.deferred()))
#	is_true(task2.is_canceled())

func 状態遷移_メソッド_超過した引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_メソッド_超過した引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_メソッド_超過した引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

#func 状態遷移_メソッド_不足した引数束縛() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method(callsite.noop_params)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait())
#	is_true(task2.is_canceled())

#func 状態遷移_メソッド_不足した引数束縛_キャンセルあり_即時() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method(callsite.noop_params)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.canceled()))
#	is_true(task2.is_canceled())

#func 状態遷移_メソッド_不足した引数束縛_キャンセルあり_遅延() -> void:
#	var callsite := Callsite.new(self)
#	var task1 := Task.completed()
#	if not is_not_null(task1):
#		return
#	var task2 := task1.then_bound_method(callsite.noop_params)
#	if not is_not_null(task2):
#		return
#	is_true(task2.is_canceled())
#	is_null(await task2.wait(Cancel.deferred()))
#	is_true(task2.is_canceled())

func 状態遷移_ラムダ() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_引数束縛() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_引数束縛_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_引数束縛_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> void:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer(), 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_引数束縛_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer()
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer()
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(func(a: int, b: int) -> int:
		are_equal(45, a)
		are_equal(78, b)
		await wait_defer()
		return a + b, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_ラムダ_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_ラムダ_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait(Cancel.canceled()))
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_ラムダ_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait(Cancel.deferred()))
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		are_equal(ref, await task2.wait()); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		is_null(await task2.wait(Cancel.canceled())); await wait_defer()
		are_equal(2, ref.get_reference_count())
		is_true(task2.is_canceled())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_bound_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		are_equal(ref, await task2.wait(Cancel.deferred())); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_ラムダ_引数束縛_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_ラムダ_引数束縛_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait(Cancel.canceled()))
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_ラムダ_引数束縛_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		are_equal(ref, await task2.wait(Cancel.deferred()))
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_引数束縛_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		are_equal(ref, await task2.wait()); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_引数束縛_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		is_null(await task2.wait(Cancel.canceled())); await wait_defer()
		are_equal(2, ref.get_reference_count())
		is_true(task2.is_canceled())
	are_equal(2, ref.get_reference_count())

func スコープ_フォーク_ラムダ_引数束縛_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			@warning_ignore("unused_parameter")
			task2 = task1.then_bound_method(func(a: int, b: int) -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref, 45, 78)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		are_equal(ref, await task2.wait(Cancel.deferred())); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_メソッド() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_キャンセルあり_重複() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_重複() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.noop_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_bound_method(callsite.fork_params_return, 45, 78)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_メソッド() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func スコープ_メソッド_引数束縛() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_引数束縛_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_引数束縛_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド_引数束縛() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_引数束縛_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_引数束縛_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func スコープ_メソッド_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func スコープ_メソッド_引数束縛_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.noop_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド_引数束縛_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_bound_method(callsite.fork_params_return, 45, 78)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())
