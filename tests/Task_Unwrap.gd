class_name Task_Unwrap extends Test

func 状態遷移_アンラップ_ネガティブ_待機_リテラル() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_アンラップ_ネガティブ_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_アンラップ_ネガティブ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_アンラップ_0_待機_リテラル() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_アンラップ_0_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_アンラップ_0_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_アンラップ_0_待機_リテラル() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_アンラップ_0_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_アンラップ_0_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_アンラップ_1_待機_リテラル() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_アンラップ_1_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_アンラップ_1_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_フォーク_アンラップ_1_待機_リテラル() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_フォーク_アンラップ_1_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_フォーク_アンラップ_1_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.from_method(func() -> int:
			await wait_defer()
			return 123) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_アンラップ_2_待機_リテラル() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_アンラップ_2_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_アンラップ_2_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(123) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_ネガティブ_待機_リテラル() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_ネスト_アンラップ_ネガティブ_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_ネスト_アンラップ_ネガティブ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_ネスト_アンラップ_0_待機_リテラル() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var unwrapped_task: Variant = await task.wait()
	is_true(task.is_completed())
	if not is_instance_of_type(unwrapped_task, Task):
		return
	is_true(unwrapped_task.is_completed())
	are_equal(123, await unwrapped_task.wait())
	is_true(unwrapped_task.is_completed())

func 状態遷移_ネスト_アンラップ_0_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var unwrapped_task: Variant = await task.wait(Cancel.canceled())
	is_true(task.is_completed())
	if not is_instance_of_type(unwrapped_task, Task):
		return
	is_true(unwrapped_task.is_completed())
	are_equal(123, await unwrapped_task.wait())
	is_true(unwrapped_task.is_completed())

func 状態遷移_ネスト_アンラップ_0_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var unwrapped_task: Variant = await task.wait(Cancel.deferred())
	is_true(task.is_completed())
	if not is_instance_of_type(unwrapped_task, Task):
		return
	is_true(unwrapped_task.is_completed())
	are_equal(123, await unwrapped_task.wait())
	is_true(unwrapped_task.is_completed())

func 状態遷移_ネスト_アンラップ_1_待機_リテラル() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_1_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_1_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_2_待機_リテラル() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_2_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_2_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(2)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_3_待機_リテラル() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(3)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait())
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_3_待機_リテラル_キャンセルあり_即時() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(3)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_ネスト_アンラップ_3_待機_リテラル_キャンセルあり_遅延() -> void:
	var task := Task \
		.completed(Task.completed(123)) \
		.unwrap(3)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(123, await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_キャンセルされたタスクから_アンラップ_ネガティブ() -> void:
	var task := Task \
		.canceled() \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_ネガティブ_キャンセルあり_即時() -> void:
	var task := Task \
		.canceled() \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_ネガティブ_キャンセルあり_遅延() -> void:
	var task := Task \
		.canceled() \
		.unwrap(-1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_0() -> void:
	var task := Task \
		.canceled() \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_0_キャンセルあり_即時() -> void:
	var task := Task \
		.canceled() \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_0_キャンセルあり_遅延() -> void:
	var task := Task \
		.canceled() \
		.unwrap(0)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_1() -> void:
	var task := Task \
		.canceled() \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_1_キャンセルあり_即時() -> void:
	var task := Task \
		.canceled() \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルされたタスクから_アンラップ_1_キャンセルあり_遅延() -> void:
	var task := Task \
		.canceled() \
		.unwrap(1)
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())
