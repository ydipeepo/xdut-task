extends MarginContainer

func _ready() -> void:
	var test_set: Array[GDScript] = [
		Cancel_Canceled,
		Cancel_WithOperators,
		Cancel_FromSignalName,
		Cancel_FromSignal,
		Cancel_FromFilteredSignalName,
		Cancel_FromFilteredSignal,
		Cancel_From,
		Cancel_Timeout,
		Cancel_Deferred,
		Cancel_Merged,
		Task_Completed,
		Task_Canceled,
		Task_Never,
		Task_WithOperators,
		Task_FromMethodName,
		Task_FromMethod,
		Task_FromBoundMethodName,
		Task_FromBoundMethod,
		Task_FromSignalName,
		Task_FromSignal,
		Task_FromFilteredSignalName,
		Task_FromFilteredSignal,
		Task_From,
		Task_ThenMethodName,
		Task_ThenMethod,
		Task_ThenBoundMethodName,
		Task_ThenBoundMethod,
		Task_Then,
		Task_All,
		Task_AllSettled,
		Task_Any,
		Task_Race,
		Task_Count,
		Task_Index,
		Task_Delay,
		Task_Defer,
		Task_DeferIdleFrame,
		Task_DeferIdle,
		Task_DeferPhysicsFrame,
		Task_DeferPhysics,
		Task_Unwrap,
		Task_Load,
	]

	if false:
		# これらのテストは実験的であり、ネットワークにアクセスします。
		# テスト時には上の条件を変更してください。
		test_set.append_array([
			Task_HTTPGet,
			Task_HTTPHead,
			Task_HTTPPost,
			Task_HTTPPut,
			Task_HTTPDelete,
			Task_HTTPOptions,
			Task_HTTPPatch,
		])

	for i: int in test_set.size():
		var test_script := test_set[i]
		var check: CheckBox = get_node("%" + test_script.get_global_name())
		check.visible = true

	var test_passed := 0
	var test_failed := 0

	for i: int in test_set.size():
		var test_script := test_set[i]
		var test: Test = test_script.new()
		%Status.text = "%d/%d Running test..." % [i + 1, test_set.size()]
		if await test.wait():
			var check: CheckBox = get_node("%" + test_script.get_global_name())
			check.button_pressed = true
			test_passed += 1
		else:
			test_failed += 1

	if test_failed == 0:
		%Status.text = "All tests passed."
	else:
		%Status.text = "%d/%d tests passed." % [test_passed, test_passed + test_failed]
