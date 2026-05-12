class_name Task_WithOperators extends Test

func 状態遷移() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())

func 状態遷移_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_canceled())

func 状態遷移_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_canceled())

func 状態遷移_呼び出し_キャンセル() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call()
	is_true(opers[0].is_canceled())
	is_null(await opers[0].wait())
	is_true(opers[0].is_canceled())

func 状態遷移_呼び出し_キャンセル_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call()
	is_true(opers[0].is_canceled())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_canceled())

func 状態遷移_呼び出し_キャンセル_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call()
	is_true(opers[0].is_canceled())
	is_null(await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_canceled())

func 状態遷移_フォーク_キャンセル() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait())
	is_true(opers[0].is_canceled())

func 状態遷移_フォーク_キャンセル_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_canceled())

func 状態遷移_フォーク_キャンセル_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[2].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_canceled())

func 状態遷移_呼び出し_完了() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call()
	is_true(opers[0].is_completed())
	is_null(await opers[0].wait())
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call()
	is_true(opers[0].is_completed())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call()
	is_true(opers[0].is_completed())
	is_null(await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_completed())

func 状態遷移_フォーク_完了() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait())
	is_true(opers[0].is_completed())

func 状態遷移_フォーク_完了_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_canceled())

func 状態遷移_フォーク_完了_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred()
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_待機_リテラル() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call(123)
	is_true(opers[0].is_completed())
	are_equal(123, await opers[0].wait())
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_待機_リテラル_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call(123)
	is_true(opers[0].is_completed())
	are_equal(123, await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_待機_リテラル_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call(123)
	is_true(opers[0].is_completed())
	are_equal(123, await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_completed())

func 状態遷移_フォーク_完了_待機_リテラル() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred(123)
	is_true(opers[0].is_pending())
	are_equal(123, await opers[0].wait())
	is_true(opers[0].is_completed())

func 状態遷移_フォーク_完了_待機_リテラル_キャンセルあり_即時() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred(123)
	is_true(opers[0].is_pending())
	is_null(await opers[0].wait(Cancel.canceled()))
	is_true(opers[0].is_canceled())

func 状態遷移_フォーク_完了_待機_リテラル_キャンセルあり_遅延() -> void:
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	is_true(opers[0].is_pending())
	opers[1].call_deferred(123)
	is_true(opers[0].is_pending())
	are_equal(123, await opers[0].wait(Cancel.deferred()))
	is_true(opers[0].is_completed())

func 状態遷移_呼び出し_完了_待機_参照() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call(ref)
		are_equal(ref, await opers[0].wait())
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func 状態遷移_呼び出し_完了_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call(ref)
		are_equal(ref, await opers[0].wait(Cancel.canceled()))
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func 状態遷移_呼び出し_完了_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call(ref)
		are_equal(ref, await opers[0].wait(Cancel.deferred()))
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func 状態遷移_フォーク_完了_待機_参照() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call_deferred(ref)
		are_equal(ref, await opers[0].wait())
		await wait_defer()
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func 状態遷移_フォーク_完了_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call_deferred(ref)
		is_null(await opers[0].wait(Cancel.canceled()))
		await wait_defer()
		are_equal(1, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())

func 状態遷移_フォーク_完了_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if true:
		var opers := Task.with_operators()
		if not is_not_empty(opers):
			return
		opers[1].call_deferred(ref)
		are_equal(ref, await opers[0].wait(Cancel.deferred()))
		await wait_defer()
		are_equal(2, ref.get_reference_count())
	are_equal(1, ref.get_reference_count())
