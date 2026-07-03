class_name Task_FromMethodName extends Test

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

func 状態遷移_名前指定あり_デフォルト() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite) # wait は未定義
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_デフォルト_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite) # wait は未定義
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_デフォルト_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite) # wait は未定義
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_空_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり_未定義_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, &"UNDEFINED")
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func スコープ_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.noop_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait())
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_名前指定あり_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	if "scope":
		var task := Task.from_method_name(callsite, callsite.fork_return.get_method())
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(2, callsite.get_reference_count())
		are_equal(123, await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(2, callsite.get_reference_count())
	are_equal(2, callsite.get_reference_count())
