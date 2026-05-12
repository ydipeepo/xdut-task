class_name Task_From extends Test

class Callsite:

	signal completed

	signal completed_params(a: int, b: int)

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
	var task := Task.from(Task.completed())
	if not is_instance_of_type(task, _FROM_CLASS):
		return
	is_true(task.is_completed())
	is_null(await task.wait())
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.from(Task.completed())
	if not is_instance_of_type(task, _FROM_CLASS):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_遅延() -> void:
	var task := Task.from(Task.completed())
	if not is_instance_of_type(task, _FROM_CLASS):
		return
	is_true(task.is_completed())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_completed())

func ディスパッチ先_from_bound_method_name() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite, callsite.noop_params_return.get_method(), [45, 78])
	if not is_instance_of_type(task, _FROM_BOUND_METHOD_NAME_CLASS):
		return
	are_equal(123, await task.wait())

func ディスパッチ先_from_bound_method() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite.noop_params_return, [45, 78])
	if not is_instance_of_type(task, _FROM_BOUND_METHOD_CLASS):
		return
	are_equal(123, await task.wait())

func ディスパッチ先_from_method_name() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite, callsite.noop_return.get_method())
	if not is_instance_of_type(task, _FROM_METHOD_NAME_CLASS):
		return
	are_equal(123, await task.wait())

func ディスパッチ先_from_method() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite.noop)
	if not is_instance_of_type(task, _FROM_METHOD_CLASS):
		return
	is_null(await task.wait())

func ディスパッチ先_from_filtered_signal_name() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite, callsite.completed_params.get_name(), [Task.SKIP, 78])
	if not is_instance_of_type(task, _FROM_FILTERED_SIGNAL_NAME_CLASS):
		return
	callsite.completed_params.emit(45, 78)
	are_equal([45, 78], await task.wait())

func ディスパッチ先_from_filtered_signal() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite.completed_params, [Task.SKIP, 78])
	if not is_instance_of_type(task, _FROM_FILTERED_SIGNAL_CLASS):
		return
	callsite.completed_params.emit(45, 78)
	are_equal([45, 78], await task.wait())

func ディスパッチ先_from_signal_name() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite, callsite.completed.get_name())
	if not is_instance_of_type(task, _FROM_SIGNAL_NAME_CLASS):
		return
	callsite.completed.emit()
	is_empty(await task.wait())

func ディスパッチ先_from_signal() -> void:
	var callsite := Callsite.new(self)
	var task := Task.from(callsite.completed)
	if not is_instance_of_type(task, _FROM_SIGNAL_CLASS):
		return
	callsite.completed.emit()
	is_empty(await task.wait())

func ディスパッチ先_completed() -> void:
	var task := Task.from(123)
	if not is_instance_of_type(task, _COMPLETED_CLASS):
		return
	are_equal(123, await task.wait())

const _COMPLETED_CLASS := preload("res://addons/godot-task/core/task/_Completed.gd")
const _FROM_BOUND_METHOD_NAME_CLASS := preload("res://addons/godot-task/core/task/_FromBoundMethodName.gd")
const _FROM_BOUND_METHOD_CLASS := preload("res://addons/godot-task/core/task/_FromBoundMethod.gd")
const _FROM_FILTERED_SIGNAL_NAME_CLASS := preload("res://addons/godot-task/core/task/_FromFilteredSignalName.gd")
const _FROM_FILTERED_SIGNAL_CLASS := preload("res://addons/godot-task/core/task/_FromFilteredSignal.gd")
const _FROM_METHOD_NAME_CLASS := preload("res://addons/godot-task/core/task/_FromMethodName.gd")
const _FROM_METHOD_CLASS := preload("res://addons/godot-task/core/task/_FromMethod.gd")
const _FROM_SIGNAL_NAME_CLASS := preload("res://addons/godot-task/core/task/_FromSignalName.gd")
const _FROM_SIGNAL_CLASS := preload("res://addons/godot-task/core/task/_FromSignal.gd")
const _FROM_CLASS := preload("res://addons/godot-task/core/task/_From.gd")
