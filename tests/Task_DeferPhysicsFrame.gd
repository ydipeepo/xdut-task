class_name Task_DeferPhysicsFrame extends Test

func 状態遷移() -> void:
	var task := Task.defer_physics_frame()
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	are_equal(0.0 if not _AUTOLOAD_CLASS.has_current() else _AUTOLOAD_CLASS.get_current().get_physics_process_delta_time(), result)
	is_true(task.is_completed())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.defer_physics_frame()
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_キャンセルあり_遅延() -> void:
	var task := Task.defer_physics_frame()
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.deferred()))
	is_true(task.is_canceled())

const _AUTOLOAD_CLASS := preload("res://addons/godot-task/core/_Autoload.gd")
