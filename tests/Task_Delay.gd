class_name Task_Delay extends Test

func 状態遷移() -> void:
	var task := Task.delay(0.1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	are_equal(0.1, await task.wait())
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.delay(0.1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルあり_遅延() -> void:
	var task := Task.delay(0.1)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

func 状態遷移_0タイムアウト() -> void:
	var task := Task.delay(0.0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(0.0, await task.wait())
	is_true(task.is_completed())

func 状態遷移_0タイムアウト_キャンセルあり_即時() -> void:
	var task := Task.delay(0.0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(0.0, await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_0タイムアウト_キャンセルあり_遅延() -> void:
	var task := Task.delay(0.0)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	are_equal(0.0, await task.wait())
	is_true(task.is_completed())
