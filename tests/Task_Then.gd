class_name Task_Then extends Test

class Callsite:

	#signal completed

	#signal completed_params(a: int, b: int)

	func noop() -> void:
		pass

	func noop_return() -> int:
		return 123

	func noop_params_return(a: int, b: int) -> int:
		_test.are_equal(a, 45)
		_test.are_equal(b, 78)
		return a + b

	var _test: Test

	func _init(test: Test) -> void:
		_test = test

func 状態遷移() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(Task.completed())
	if not is_true(task2 is _THEN_CLASS):
		return
	is_null(await task2.wait())

func 状態遷移_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(Task.completed())
	if not is_true(task2 is _THEN_CLASS):
		return
	is_null(await task2.wait(Cancel.canceled()))

func 状態遷移_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(Task.completed())
	if not is_true(task2 is _THEN_CLASS):
		return
	is_null(await task2.wait(Cancel.deferred()))

func ディスパッチ先_then_bound_method_name() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(callsite, callsite.noop_params_return.get_method(), [45, 78])
	if not is_true(task2 is _THEN_BOUND_METHOD_NAME_CLASS):
		return
	are_equal(123, await task2.wait())

func ディスパッチ先_then_bound_method() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(callsite.noop_params_return, [45, 78])
	if not is_true(task2 is _THEN_BOUND_METHOD_CLASS):
		return
	are_equal(123, await task2.wait())

func ディスパッチ先_then_method_name() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(callsite, callsite.noop_return.get_method())
	if not is_true(task2 is _THEN_METHOD_NAME_CLASS):
		return
	are_equal(123, await task2.wait())

func ディスパッチ先_then_method() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then(callsite.noop_return)
	if not is_true(task2 is _THEN_METHOD_CLASS):
		return
	are_equal(123, await task2.wait())

const _THEN_BOUND_METHOD_NAME_CLASS := preload("res://addons/godot-task/core/task/_ThenBoundMethodName.gd")
const _THEN_BOUND_METHOD_CLASS := preload("res://addons/godot-task/core/task/_ThenBoundMethod.gd")
const _THEN_METHOD_NAME_CLASS := preload("res://addons/godot-task/core/task/_ThenMethodName.gd")
const _THEN_METHOD_CLASS := preload("res://addons/godot-task/core/task/_ThenMethod.gd")
const _THEN_CLASS := preload("res://addons/godot-task/core/task/_Then.gd")
