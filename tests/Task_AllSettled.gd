class_name Task_AllSettled extends Test

class TestTask extends Task:

	func get_name() -> StringName:
		return &"TestTask"

	func get_state() -> int:
		return _state

	func wait(cancel: Cancel = null) -> Variant:
		if _state == STATE_PENDING:
			_state = STATE_PENDING_WITH_WAITERS
		if _state == STATE_PENDING_WITH_WAITERS:
			if not is_instance_valid(cancel) or cancel.requested.is_connected(release_cancel):
				await _release
			elif not cancel.is_requested():
				cancel.requested.connect(release_cancel)
				await _release
				cancel.requested.disconnect(release_cancel)
			else:
				release_cancel()
		return null

	func release_complete() -> void:
		match _state:
			STATE_PENDING:
				_state = STATE_COMPLETED
			STATE_PENDING_WITH_WAITERS:
				_state = STATE_COMPLETED
				_release.emit()

	func release_cancel() -> void:
		match _state:
			STATE_PENDING:
				_state = STATE_CANCELED
			STATE_PENDING_WITH_WAITERS:
				_state = STATE_CANCELED
				_release.emit()

	signal _release

	var _state: int = STATE_PENDING

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

func カスケード_CustomTask_派生() -> void:
	var opers1 := Task.with_operators()
	if not is_not_empty(opers1):
		return
	var opers2 := Task.with_operators()
	if not is_not_empty(opers2):
		return
	var task := Task.all_settled(opers1[0], opers2[0])
	if not is_not_null(task):
		return
	is_true(opers1[0].is_pending())
	is_true(opers2[0].is_pending())
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(opers1[0].is_pending())
	is_true(opers2[0].is_pending())
	is_true(task.is_canceled())

func カスケード_CustomTask_派生_キャンセルあり_即時() -> void:
	var opers1 := Task.with_operators()
	if not is_not_empty(opers1):
		return
	var opers2 := Task.with_operators()
	if not is_not_empty(opers2):
		return
	var task := Task.all_settled(opers1[0], opers2[0])
	if not is_not_null(task):
		return
	is_true(opers1[0].is_pending())
	is_true(opers2[0].is_pending())
	is_true(task.is_pending())
	opers1[1].call_deferred()
	is_null(await task.wait(Cancel.deferred()))
	is_true(opers1[0].is_completed())
	is_true(opers2[0].is_pending())
	is_true(task.is_canceled())

func カスケード_CustomTask_派生_キャンセルあり_遅延() -> void:
	var opers1 := Task.with_operators()
	if not is_not_empty(opers1):
		return
	var opers2 := Task.with_operators()
	if not is_not_empty(opers2):
		return
	var task := Task.all_settled(opers1[0], opers2[0])
	if not is_not_null(task):
		return
	is_true(opers1[0].is_pending())
	is_true(opers2[0].is_pending())
	is_true(task.is_pending())
	opers1[2].call_deferred()
	is_null(await task.wait(Cancel.deferred()))
	is_true(opers1[0].is_canceled())
	is_true(opers2[0].is_pending())
	is_true(task.is_canceled())

func カスケード_Task_派生() -> void:
	var task1 := TestTask.new()
	var task2 := TestTask.new()
	var task3 := Task.all_settled(task1, task2)
	if not is_not_null(task3):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	is_true(task3.is_pending())
	is_null(await task3.wait(Cancel.deferred()))
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_true(task3.is_canceled())

func カスケード_Task_派生_キャンセルあり_即時() -> void:
	var task1 := TestTask.new()
	var task2 := TestTask.new()
	var task3 := Task.all_settled(task1, task2)
	if not is_not_null(task3):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	is_true(task3.is_pending())
	task1.release_complete.call_deferred()
	is_null(await task3.wait(Cancel.deferred()))
	is_true(task1.is_completed())
	is_true(task2.is_canceled())
	is_true(task3.is_canceled())

func カスケード_Task_派生_キャンセルあり_遅延() -> void:
	var task1 := TestTask.new()
	var task2 := TestTask.new()
	var task3 := Task.all_settled(task1, task2)
	if not is_not_null(task3):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	is_true(task3.is_pending())
	task1.release_cancel.call_deferred()
	is_null(await task3.wait(Cancel.deferred()))
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	is_true(task3.is_canceled())

func 状態遷移_入力_空() -> void:
	var task := Task.all_settled()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_empty(await task.wait())
	is_true(task.is_completed())

func 状態遷移_入力_空_キャンセルあり_即時() -> void:
	var task := Task.all_settled()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_empty(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_入力_空_キャンセルあり_遅延() -> void:
	var task := Task.all_settled()
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	is_empty(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func 状態遷移_入力_リテラル() -> void:
	var task := Task.all_settled(12, 34, 56)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_リテラル_キャンセルあり_即時() -> void:
	var task := Task.all_settled(12, 34, 56)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.canceled())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_リテラル_キャンセルあり_遅延() -> void:
	var task := Task.all_settled(12, 34, 56)
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_即時_ラップされたリテラル() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.completed(56))
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_即時_ラップされたリテラル_キャンセルあり_即時() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.completed(56))
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.canceled())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_即時_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.completed(56))
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_混合_ラップされたリテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, callsite.noop_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_混合_ラップされたリテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, callsite.noop_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_入力_混合_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, callsite.noop_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_遅延_ラップされたリテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, callsite.fork_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_遅延_ラップされたリテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, callsite.fork_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_入力_遅延_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, callsite.fork_return)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_completed())

func 状態遷移_入力_即時_キャンセル含む_リテラル() -> void:
	var task := Task.all_settled(12, 34, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_即時_キャンセル含む_リテラル_キャンセルあり_即時() -> void:
	var task := Task.all_settled(12, 34, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.canceled())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_即時_キャンセル含む_リテラル_キャンセルあり_遅延() -> void:
	var task := Task.all_settled(12, 34, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_即時_キャンセル含む_ラップされたリテラル() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_即時_キャンセル含む_ラップされたリテラル_キャンセルあり_即時() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.canceled())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_即時_キャンセル含む_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var task := Task.all_settled(Task.completed(12), Task.completed(34), Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_completed())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_混合_キャンセル含む_ラップされたリテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_混合_キャンセル含む_ラップされたリテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_入力_混合_キャンセル含む_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.noop_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_遅延_キャンセル含む_ラップされたリテラル() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())

func 状態遷移_入力_遅延_キャンセル含む_ラップされたリテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_入力_遅延_キャンセル含む_ラップされたリテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task := Task.all_settled(callsite.fork_return, callsite.fork_return, Task.canceled())
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait(Cancel.deferred())
	if not is_instance_of_type(result, TYPE_ARRAY):
		return
	is_true(task.is_completed())
	is_true(result[0].is_completed())
	is_true(result[1].is_completed())
	is_true(result[2].is_canceled())
