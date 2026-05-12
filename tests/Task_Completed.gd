class_name Task_Completed extends Test

func 状態遷移() -> void:
	var task := Task.completed()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.completed()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_遅延() -> void:
	var task := Task.completed()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_待機_リテラル() -> void:
	var task := Task.completed(123)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task.completed(123)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task.completed(123)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func スコープ_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task := Task.completed(ref)
		if not is_not_null(task):
			return
		is_true(task.is_completed())
		are_equal(ref, await task.wait())
		is_true(task.is_completed())
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func スコープ_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task := Task.completed(ref)
		if not is_not_null(task):
			return
		is_true(task.is_completed())
		are_equal(ref, await task.wait(Cancel.canceled()))
		is_true(task.is_completed())
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func スコープ_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task := Task.completed(ref)
		if not is_not_null(task):
			return
		is_true(task.is_completed())
		are_equal(ref, await task.wait(Cancel.deferred()))
		is_true(task.is_completed())
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())
