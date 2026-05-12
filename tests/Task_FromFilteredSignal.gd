class_name Task_FromFilteredSignal extends Test

class Callsite:

	signal completed

	signal completed_params(a: int, b: int)

func 状態遷移_空() -> void:
	var task := Task.from_filtered_signal(Signal())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_空_キャンセルあり_即時() -> void:
	var task := Task.from_filtered_signal(Signal())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_空_キャンセルあり_遅延() -> void:
	var task := Task.from_filtered_signal(Signal())
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_空_フィルタ() -> void:
	var task := Task.from_filtered_signal(Signal(), Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_空_フィルタ_キャンセルあり_即時() -> void:
	var task := Task.from_filtered_signal(Signal(), Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_空_フィルタ_キャンセルあり_遅延() -> void:
	var task := Task.from_filtered_signal(Signal(), Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_シグナル() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit()
	is_true(task.is_completed())
	is_empty(await task.wait())
	is_true(task.is_completed())

func 状態遷移_シグナル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit()
	is_true(task.is_completed())
	is_empty(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_シグナル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit()
	is_true(task.is_completed())
	is_empty(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_シグナル() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit.call_deferred()
	is_true(task.is_pending())
	is_empty(await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_シグナル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit.call_deferred()
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_シグナル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed.emit.call_deferred()
	is_true(task.is_pending())
	is_empty(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_シグナル_フィルタ() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 12)
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 78)
	is_true(task.is_completed())
	callsite.completed_params.emit(45, 34)
	is_true(task.is_completed())
	are_equal([45, 78], await task.wait())
	is_true(task.is_completed())

func 状態遷移_シグナル_フィルタ_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 12)
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 78)
	is_true(task.is_completed())
	callsite.completed_params.emit(45, 34)
	is_true(task.is_completed())
	are_equal([45, 78], await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_シグナル_フィルタ_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 12)
	is_true(task.is_pending())
	callsite.completed_params.emit(45, 78)
	is_true(task.is_completed())
	callsite.completed_params.emit(45, 34)
	is_true(task.is_completed())
	are_equal([45, 78], await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_シグナル_フィルタ() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit.call_deferred(45, 78)
	is_true(task.is_pending())
	are_equal([45, 78], await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_シグナル_フィルタ_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit.call_deferred(45, 78)
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_シグナル_フィルタ_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	callsite.completed_params.emit.call_deferred(45, 78)
	is_true(task.is_pending())
	are_equal([45, 78], await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func スコープ_シグナル() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_empty(await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_シグナル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_empty(await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_シグナル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		is_empty(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit.call_deferred()
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		is_empty(await task.wait())
		is_true(task.is_completed()); are_equal(3, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit.call_deferred()
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed.emit.call_deferred()
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		is_empty(await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(3, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_シグナル_フィルタ() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 12)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 78)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 34)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal([45, 78], await task.wait())
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_シグナル_フィルタ_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 12)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 78)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 34)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal([45, 78], await task.wait(Cancel.canceled()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_シグナル_フィルタ_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 12)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 78)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit(45, 34)
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
		are_equal([45, 78], await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル_フィルタ() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit.call_deferred(45, 78)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		are_equal([45, 78], await task.wait())
		is_true(task.is_completed()); are_equal(3, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル_フィルタ_キャンセルあり_即時() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit.call_deferred(45, 78)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		is_null(await task.wait(Cancel.canceled()))
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_canceled()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_フォーク_シグナル_フィルタ_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new()
	if "scope":
		var task := Task.from_filtered_signal(callsite.completed_params, Task.SKIP, 78)
		if not is_not_null(task):
			return
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		callsite.completed_params.emit.call_deferred(45, 78)
		is_true(task.is_pending()); are_equal(1, callsite.get_reference_count())
		are_equal([45, 78], await task.wait(Cancel.deferred()))
		is_true(task.is_completed()); are_equal(3, callsite.get_reference_count())
		await wait_defer()
		is_true(task.is_completed()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())
