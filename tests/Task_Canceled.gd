class_name Task_Canceled extends Test

func 状態遷移() -> void:
	var task := Task.canceled()
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.canceled()
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルあり_遅延() -> void:
	var task := Task.canceled()
	if not is_not_null(task):
		return
	is_true(task.is_canceled())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())
