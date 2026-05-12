class_name Task_Load extends Test

func 状態遷移_無効() -> void:
	var task := Task.load("res://scenes/Dummy_NOT_FOUND.tscn", &"PackedScene")
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait())
	is_true(task.is_canceled())

func 状態遷移_単一() -> void:
	var task := Task.load("res://scenes/Dummy.tscn", &"PackedScene")
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var result: Variant = await task.wait()
	is_true(task.is_completed())
	if not is_instance_of_type(result, PackedScene):
		return
	var dummy: Variant = result.instantiate()
	if not is_instance_of_type(dummy, Control):
		return
	if not is_true(&"value" in dummy):
		return
	is_true(dummy.value)

func 状態遷移_単一_キャンセルあり_即時() -> void:
	var task := Task.load("res://scenes/Dummy.tscn", &"PackedScene")
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())

func 状態遷移_複数() -> void:
	var task1 := Task.load("res://scenes/Dummy.tscn", &"PackedScene")
	if not is_not_null(task1):
		return
	var task2 := Task.load("res://scenes/Dummy.tscn", &"PackedScene")
	if not is_not_null(task2):
		return
	var task3 := Task.load("res://scenes/Dummy.tscn", &"PackedScene")
	if not is_not_null(task3):
		return
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	is_true(task3.is_pending())
	var result1: Variant = await task1.wait()
	var result2: Variant = await task2.wait()
	var result3: Variant = await task3.wait()
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	is_true(task3.is_completed())
	if not is_instance_of_type(result1, PackedScene):
		return
	if not is_instance_of_type(result2, PackedScene):
		return
	if not is_instance_of_type(result3, PackedScene):
		return
	var dummy1: Variant = result1.instantiate()
	var dummy2: Variant = result2.instantiate()
	var dummy3: Variant = result3.instantiate()
	if not is_instance_of_type(dummy1, Control):
		return
	if not is_instance_of_type(dummy2, Control):
		return
	if not is_instance_of_type(dummy3, Control):
		return
	if not is_true(&"value" in dummy1):
		return
	if not is_true(&"value" in dummy2):
		return
	if not is_true(&"value" in dummy3):
		return
	is_true(dummy1.value)
	is_true(dummy2.value)
	is_true(dummy3.value)
