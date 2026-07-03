class_name Task_FromBoundMethodName extends Test

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

func 状態遷移_名前指定あり_空() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, &"UNDEFINED", 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_超過した引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_不足した引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_不足した引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_不足した引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_待機() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func スコープ_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_引数束縛() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_引数束縛() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_引数束縛_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_引数束縛_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.noop_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_引数束縛_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_引数束縛_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_引数束縛_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_bound_method_name(callsite, callsite.fork_params_return.get_method(), 45, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())
