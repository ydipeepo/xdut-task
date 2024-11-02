extends MarginContainer

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func wait_defer() -> void:
	var s := Scope.new()
	await s.from_deferred()

func wait_defer_process() -> void:
	# テスト用
	var main_loop := Engine.get_main_loop()
	var canonical: Node = main_loop.root.get_node("/root/XDUT_TaskCanonical")
	assert(canonical != null)
	await canonical.process

func wait_defer_process_frame() -> void:
	# テスト用
	var main_loop := Engine.get_main_loop()
	var canonical: Node = main_loop.root.get_node("/root/XDUT_TaskCanonical")
	assert(canonical != null)
	await canonical.process_frame

func wait_defer_physics() -> void:
	# テスト用
	var main_loop := Engine.get_main_loop()
	var canonical: Node = main_loop.root.get_node("/root/XDUT_TaskCanonical")
	assert(canonical != null)
	await canonical.physics

func wait_defer_physics_frame() -> void:
	# テスト用
	var main_loop := Engine.get_main_loop()
	var canonical: Node = main_loop.root.get_node("/root/XDUT_TaskCanonical")
	assert(canonical != null)
	await canonical.physics_frame

func wait_delay(timeout: float) -> void:
	# テスト用
	var main_loop := Engine.get_main_loop()
	var canonical: Node = main_loop.root.get_node("/root/XDUT_TaskCanonical")
	assert(canonical != null)
	await canonical.create_timer(timeout).timeout

func wait_equal(task: Task, array2: Array, cancel: Cancel = null) -> bool:
	var array1: Variant = await task.wait(cancel)
	if array1 == null or array1.size() != array2.size():
		return false
	for i: int in array1.size():
		if typeof(array1[i]) != typeof(array2[i]) or array1[i] != array2[i]:
			return false
	return true

func wait_equal_deep(task: Task, array2: Array, cancel: Cancel = null) -> bool:
	var array1: Variant = await task.wait(cancel)
	if array1 == null or array1.size() != array2.size():
		return false
	for i: int in array1.size():
		var value1: Variant = array1[i]
		var value2: Variant = array2[i]
		if value1 is Task and value2 is Task:
			await value1.wait(cancel)
			await value2.wait(cancel)
			if value1.get_state() != value2.get_state():
				return false
			value1 = value1.wait()
			value2 = value2.wait()
		if value1 is Task:
			await value1.wait(cancel)
			if value1.is_canceled:
				return false
			value1 = value1.wait()
		if value2 is Task:
			await value2.wait(cancel)
			if value2.is_canceled:
				return false
			value2 = value2.wait()
		if typeof(value1) != typeof(value2) or value1 != value2:
			return false
	return true

func test_completed() -> void:
	var t: Task
	
	t = Task.completed()
	assert(t.is_completed)
	assert(await t.wait() == null)
	assert(t.is_completed)

	t = Task.completed(Scope.RETURN)
	assert(t.is_completed)
	assert(await t.wait() == Scope.RETURN)
	assert(t.is_completed)

	t = Task.completed()
	assert(t.is_completed)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_completed)

	t = Task.completed(Scope.RETURN)
	assert(t.is_completed)
	assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
	assert(t.is_completed)

	%Completed.button_pressed = true

func test_canceled() -> void:
	var t: Task

	t = Task.canceled()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.canceled()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	%Canceled.button_pressed = true

func test_never() -> void:
	var t: Task
	
	if "キャンセルなし":
		
		t = Task.never()
		assert(t.is_pending)
		#assert(await t.wait() == null)
		#assert(t.is_canceled)

		t = Task.never(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "即時キャンセル":

		t = Task.never()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "遅延キャンセル":

		t = Task.never()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.never(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)
		
	%Never.button_pressed = true

func test_from() -> void:
	var g: Scope
	var t: Task

	if "配列 3 要素":

		g = Scope.new(); t = Task.from([g, &"signal_1", 1])
		assert(t.is_pending)
		g.emit_signal_1()
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g, &"signal_1", [Scope.ARG1]])
		assert(t.is_pending)
		g.emit_signal_1(null)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

	if "配列 2 要素":

		g = Scope.new(); t = Task.from([g, &"from_immediate"])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g, &"signal_0"])
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g.signal_1, 1])
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g.signal_1, [Scope.ARG1]])
		assert(t.is_pending)
		g.emit_signal_1(null)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)
	
	if "配列 1 要素":

		g = Scope.new(); t = Task.from([Task.completed()])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)
		
		g = Scope.new(); t = Task.from([Task.canceled()])
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
		
		g = Scope.new(); t = Task.from([Task.defer()])
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)	
		
		g = ScopeWithWait.new(); t = Task.from([g])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = ScopeWithCompleted.new(); t = Task.from([g])
		assert(t.is_pending)
		g.emit()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g.from_immediate])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from([g.signal_0])
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

	if "他":

		g = Scope.new(); t = Task.from(Task.completed())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)
		
		g = Scope.new(); t = Task.from(Task.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
		
		g = Scope.new(); t = Task.from(Task.defer())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)
		
		g = ScopeWithWait.new(); t = Task.from(g)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = ScopeWithCompleted.new(); t = Task.from(g)
		assert(t.is_pending)
		g.emit()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from(g.from_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from(g.signal_0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

	%From.button_pressed = true

func test_from_method() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_method(g.from_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return)
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_method(g.from_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_method(g.from_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method(g.from_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted":

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と即時キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と遅延キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_method(l.from_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%FromMethod.button_pressed = true

func test_from_method_name() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate")
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return")
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return")
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_method_name(g, &"from_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%FromMethodName.button_pressed = true

func test_from_callback() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback(g.from_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted":

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と即時キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と遅延キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_callback(l.from_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%FromCallback.button_pressed = true

func test_from_callback_name() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_callback_name(g, &"from_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%FromCallbackName.button_pressed = true

func test_from_signal() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_0, 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_1, 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_2, 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_3, 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_4, 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal(g.signal_5, 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

	if "到達不能な RefCounted":

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

	if "到達不能な RefCounted と即時キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

	if "到達不能な RefCounted と遅延キャンセル":

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_0, 0, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_1, 1, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_2, 2, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_3, 3, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_4, 4, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.from_signal(l.signal_5, 5, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

	%FromSignal.button_pressed = true

func test_from_signal_name() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, []))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.canceled()))
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0)
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_0", 0, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_0()
		assert(t.is_canceled)
		assert(not await wait_equal(t, [], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_1", 1, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_2", 2, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_3", 3, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_4", 4, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.canceled())
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_completed)

		g = Scope.new(); t = Task.from_signal_name(g, &"signal_5", 5, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_canceled)
		assert(not await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5], Cancel.deferred()))
		assert(t.is_canceled)

	%FromSignalName.button_pressed = true

func test_from_conditional_signal() -> void:
	var g: Scope
	var t: Task

	if "0 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_0, [])
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))

	if "1 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_1, [Scope.ARG1])
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG2)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_1, [Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))

	if "2 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_2, [Scope.ARG1, Scope.ARG2])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_2, [Task.SKIP, Scope.ARG2])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_2, [Scope.ARG1, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_2, [Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

	if "3 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Scope.ARG1, Scope.ARG2, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		
		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Task.SKIP, Scope.ARG2, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Scope.ARG1, Task.SKIP, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Task.SKIP, Task.SKIP, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Scope.ARG1, Scope.ARG2, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Task.SKIP, Scope.ARG2, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Scope.ARG1, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_3, [Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

	if "4 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		
		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		
		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_4, [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

	if "5 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		
		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		
		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal(g.signal_5, [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

	%FromConditionalSignal.button_pressed = true

func test_from_conditional_signal_name() -> void:
	var g: Scope
	var t: Task

	if "0 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_0", [])
		assert(t.is_pending)
		g.emit_signal_0()
		assert(t.is_completed)
		assert(await wait_equal(t, []))

	if "1 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_1", [Scope.ARG1])
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG2)
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_1", [Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_1(Scope.ARG1)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1]))

	if "2 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_2", [Scope.ARG1, Scope.ARG2])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_2", [Task.SKIP, Scope.ARG2])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_2", [Scope.ARG1, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG2, Scope.ARG3)
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_2", [Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_2(Scope.ARG1, Scope.ARG2)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2]))

	if "3 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Scope.ARG1, Scope.ARG2, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))
		
		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Task.SKIP, Scope.ARG2, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Scope.ARG1, Task.SKIP, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Task.SKIP, Task.SKIP, Scope.ARG3])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Scope.ARG1, Scope.ARG2, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Task.SKIP, Scope.ARG2, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Scope.ARG1, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_3", [Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_3(Scope.ARG1, Scope.ARG2, Scope.ARG3)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3]))

	if "4 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		
		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))
		
		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_4", [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_4(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4]))

	if "5 個の引数":

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		
		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG5])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))
		
		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Scope.ARG3, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Task.SKIP, Scope.ARG4, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Scope.ARG3, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Scope.ARG2, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Scope.ARG2, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Scope.ARG1, Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5, Scope.ARG1)
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

		g = Scope.new(); t = Task.from_conditional_signal_name(g, &"signal_5", [Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP, Task.SKIP])
		assert(t.is_pending)
		g.emit_signal_5(Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5)
		assert(t.is_completed)
		assert(await wait_equal(t, [Scope.ARG1, Scope.ARG2, Scope.ARG3, Scope.ARG4, Scope.ARG5]))

	%FromConditionalSignalName.button_pressed = true

func test_all() -> void:
	var t: Task
	var p: Permutation

	t = Task.all([])
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, []))
	assert(t.is_canceled)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all([])
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_canceled)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all([])
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	t = Task.all([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_canceled)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	t = Task.all([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	if "直値":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push(Scope.ARG1)
			p.push(Scope.ARG2)
			p.push(Scope.ARG3)
			while p.next():
				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)
				
				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)
				
				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)
				
				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)
				
				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)
				
				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)
				
				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

	if "ラップされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_completed(Scope.ARG1)
			p.push_completed(Scope.ARG2)
			p.push_completed(Scope.ARG3)
			while p.next():
				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

	if "キャンセルされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_canceled()
			p.push_canceled()
			p.push_canceled()
			while p.next():
				t = Task.all(p.get_inputs())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

	if "遷移":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_defer()
			p.push_defer()
			p.push_defer()
			while p.next():
				t = Task.all(p.get_inputs())
				assert(t.is_pending)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_pending)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs())
				assert(t.is_pending)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

	%All.button_pressed = true

func test_all_settled() -> void:
	var t: Task
	var p: Permutation

	t = Task.all_settled([])
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, []))
	assert(t.is_canceled)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, []))
	assert(t.is_completed)

	t = Task.all_settled([])
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_canceled)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.canceled()))
	assert(t.is_completed)

	t = Task.all_settled([])
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.canceled())
	assert(t.is_canceled)
	assert(not await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_canceled)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	t = Task.all_settled([], Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await wait_equal(t, [], Cancel.deferred()))
	assert(t.is_completed)

	if "直値":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push(Scope.ARG1)
			p.push(Scope.ARG2)
			p.push(Scope.ARG3)
			while p.next():
				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_canceled)
				
				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)
				
				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_canceled)
				
				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)
				
				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_canceled)
				
				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

	if "ラップされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_completed(Scope.ARG1)
			p.push_completed(Scope.ARG2)
			p.push_completed(Scope.ARG3)
			while p.next():
				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

	if "キャンセルされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_canceled()
			p.push_canceled()
			p.push_canceled()
			while p.next():
				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_inputs(), Cancel.deferred()))
				assert(t.is_completed)

	if "遷移":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_defer()
			p.push_defer()
			p.push_defer()
			while p.next():
				t = Task.all_settled(p.get_inputs())
				assert(t.is_pending)
				assert(await wait_equal_deep(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_outputs()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await wait_equal_deep(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_outputs()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_pending)
				assert(not await wait_equal_deep(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(not await wait_equal_deep(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_outputs(), Cancel.canceled()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs())
				assert(t.is_pending)
				assert(await wait_equal_deep(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(not await wait_equal_deep(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_canceled)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await wait_equal_deep(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

				t = Task.all_settled(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await wait_equal_deep(t, p.get_outputs(), Cancel.deferred()))
				assert(t.is_completed)

	%AllSettled.button_pressed = true

func test_any() -> void:
	var t: Task
	var p: Permutation

	t = Task.any([])
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.any([])
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.any([])
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.any([], Cancel.deferred())
	assert(t.is_canceled)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	if "直値":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push(Scope.ARG1)
			p.push(Scope.ARG2)
			p.push(Scope.ARG3)
			while p.next():
				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)
				
				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)
				
				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)
				
				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)
				
				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)
				
				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)
				
				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

	if "ラップされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_completed(Scope.ARG1)
			p.push_completed(Scope.ARG2)
			p.push_completed(Scope.ARG3)
			while p.next():
				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

	if "キャンセルされたタスク":
		
		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_canceled()
			p.push_canceled()
			p.push_canceled()
			while p.next():
				t = Task.any(p.get_inputs())
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(await t.wait() == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_canceled)
				await wait_defer()
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

	if "遷移":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_defer()
			p.push_defer()
			p.push_defer()
			while p.next():
				t = Task.any(p.get_inputs())
				assert(t.is_pending)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait() == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_pending)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await t.wait(Cancel.canceled()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.canceled()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs())
				assert(t.is_pending)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				assert(await t.wait(Cancel.deferred()) == null)
				assert(t.is_canceled)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

				t = Task.any(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				assert(await t.wait(Cancel.deferred()) == p.get_output(0))
				assert(t.is_completed)

	%Any.button_pressed = true

func test_race() -> void:
	var t: Task
	var u: Task
	var p: Permutation
	
	t = Task.race([])
	assert(t.is_pending)

	t = Task.race([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.race([])
	assert(t.is_pending)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.race([])
	assert(t.is_pending)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.race([], Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	if "直値":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push(Scope.ARG1)
			p.push(Scope.ARG2)
			p.push(Scope.ARG3)
			while p.next():
				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait()
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.deferred())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

	if "ラップされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_completed(Scope.ARG1)
			p.push_completed(Scope.ARG2)
			p.push_completed(Scope.ARG3)
			while p.next():
				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait()
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.deferred())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

	if "キャンセルされたタスク":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_canceled()
			p.push_canceled()
			p.push_canceled()
			while p.next():
				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait() == null)
				assert(u.is_canceled)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait()
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait() == null)
				assert(u.is_canceled)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait() == null)
				assert(u.is_canceled)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.canceled()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.canceled()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.canceled()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.deferred()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.deferred())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.deferred()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_completed)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_canceled)
				assert(await u.wait(Cancel.deferred()) == null)
				assert(u.is_canceled)
				assert(t.is_completed)

	if "遷移":

		for d: int in 2:
			p = Permutation.new(d + 1)
			p.push_defer()
			p.push_defer()
			p.push_defer()
			while p.next():
				t = Task.race(p.get_inputs())
				assert(t.is_pending)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait()
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait()
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_pending)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				u = await t.wait(Cancel.canceled())
				assert(u == null)
				assert(t.is_canceled)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.canceled())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs())
				assert(t.is_pending)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait() == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)
				
				t = Task.race(p.get_inputs(), Cancel.canceled())
				assert(t.is_canceled)
				u = await t.wait(Cancel.deferred())
				assert(u == null)
				assert(t.is_canceled)
				
				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.canceled()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

				t = Task.race(p.get_inputs(), Cancel.deferred())
				assert(t.is_pending)
				await wait_defer()
				assert(t.is_completed)
				u = await t.wait(Cancel.deferred())
				assert(u is Task)
				assert(u.is_completed)
				assert(await u.wait(Cancel.deferred()) == p.get_output(0))
				assert(u.is_completed)
				assert(t.is_completed)

	%Race.button_pressed = true

func test_defer() -> void:
	var t: Task

	if "キャンセルなし":

		t = Task.defer()
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		t = Task.defer()
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

	if "即時キャンセル":

		t = Task.defer()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer()
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

	if "遅延キャンセル":

		t = Task.defer()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		t = Task.defer()
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		t = Task.defer(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

	%Defer.button_pressed = true

func test_defer_process_frame() -> void:
	var t: Task

	if "キャンセルなし":

		t = Task.defer_process_frame()
		assert(t.is_pending)
		assert(await t.wait() == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process_frame()
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_completed)
		assert(await t.wait() == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
	
	if "即時キャンセル":

		t = Task.defer_process_frame()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame()
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "遅延キャンセル":

		t = Task.defer_process_frame()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame()
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%DeferProcessFrame.button_pressed = true

func test_defer_physics_frame() -> void:
	var t: Task

	if "キャンセルなし":

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		assert(await t.wait() == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_completed)
		assert(await t.wait() == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
	
	if "即時キャンセル":

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "遅延キャンセル":

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame()
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics_frame(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics_frame()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%DeferPhysicsFrame.button_pressed = true

func test_defer_process() -> void:
	var t: Task

	if "キャンセルなし":

		t = Task.defer_process()
		assert(t.is_pending)
		assert(await t.wait() == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process()
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_completed)
		assert(await t.wait() == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
	
	if "即時キャンセル":

		t = Task.defer_process()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process()
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "遅延キャンセル":

		t = Task.defer_process()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process()
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == get_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_process(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_process()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "タイミング":

		const ITERATIONS := 10
		
		_samples.clear()
		_requested_samples = ITERATIONS
		set_process(true)
		for _i: int in ITERATIONS:
			var delta: float = await Task.wait_defer_process()
			_samples.push_back({
				"origin": "await",
				"delta": delta,
			})
		await wait_defer()
		assert(_samples.size() == ITERATIONS * 2)
		for i: int in ITERATIONS:
			var sample1 := _samples[i * 2 + 0]
			var sample2 := _samples[i * 2 + 1]
			assert(sample1.origin == "await")
			assert(sample2.origin == "local")
			assert(is_equal_approx(sample1.delta, sample2.delta))

	%DeferProcess.button_pressed = true

func test_defer_physics() -> void:
	var t: Task

	if "キャンセルなし":

		t = Task.defer_physics()
		assert(t.is_pending)
		assert(await t.wait() == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics()
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_completed)
		assert(await t.wait() == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)
	
	if "即時キャンセル":

		t = Task.defer_physics()
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics()
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "遅延キャンセル":

		t = Task.defer_physics()
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics()
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == get_physics_process_delta_time())
		assert(t.is_completed)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.canceled())
		assert(t.is_canceled)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		t = Task.defer_physics(Cancel.deferred())
		assert(t.is_pending)
		await wait_defer_physics()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "タイミング":

		const ITERATIONS := 10
		
		_samples.clear()
		_requested_samples = ITERATIONS
		set_physics_process(true)
		for _i: int in ITERATIONS:
			var delta: float = await Task.wait_defer_physics()
			_samples.push_back({
				"origin": "await",
				"delta": delta,
			})
		await wait_defer()
		assert(_samples.size() == ITERATIONS * 2)
		for i: int in ITERATIONS:
			var sample1 := _samples[i * 2 + 0]
			var sample2 := _samples[i * 2 + 1]
			assert(sample1.origin == "await")
			assert(sample2.origin == "local")
			assert(is_equal_approx(sample1.delta, sample2.delta))

	%DeferPhysics.button_pressed = true

func test_delay() -> void:
	var t: Task

	t = Task.delay(-0.1, false, false)
	assert(t.is_completed)
	assert(await t.wait() == null)
	assert(t.is_completed)

	t = Task.delay(0.0, false, false)
	assert(t.is_completed)
	assert(await t.wait() == null)
	assert(t.is_completed)
	
	t = Task.delay(0.1, false, false)
	assert(t.is_pending)
	assert(await t.wait() == null)
	assert(t.is_completed)

	t = Task.delay(0.1, false, false, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false)
	assert(t.is_pending)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.canceled()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false)
	assert(t.is_pending)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	t = Task.delay(0.1, false, false, Cancel.deferred())
	assert(t.is_pending)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait(Cancel.deferred()) == null)
	assert(t.is_canceled)

	%Delay.button_pressed = true

func test_delay_msec() -> void:
	var t: Task
	
	t = Task.delay_msec(100)
	assert(t.is_pending)
	assert(await t.wait() == null)
	assert(t.is_completed)

	%DelayMsec.button_pressed = true

func test_delay_usec() -> void:
	var t: Task
	
	t = Task.delay_usec(100_000)
	assert(t.is_pending)
	assert(await t.wait() == null)
	assert(t.is_completed)

	%DelayUsec.button_pressed = true

func test_then() -> void:
	var g: Scope
	var t: Task

	if "配列 2 要素":

		g = Scope.new(); t = Task.completed().then([g, &"from_immediate"])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)
	
	if "配列 1 要素":

		g = ScopeWithWait.new(); t = Task.completed().from([g])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().from([g.from_immediate])
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

	if "他":

		g = Scope.new(); t = Task.completed().then(Task.completed())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)
		
		g = ScopeWithWait.new(); t = Task.completed().then(g)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then(g.from_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

	%Then.button_pressed = true

func test_then_method() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return)
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method(g.then_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted":

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と即時キャンセル":

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と遅延キャンセル":

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_method(l.then_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%ThenMethod.button_pressed = true

func test_then_method_name() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate")
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return")
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return")
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_method_name(g, &"then_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)
	
	%ThenMethodName.button_pressed = true

func test_then_callback() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_return, Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_immediate_cancel, Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_return, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback(g.then_callback_deferred_cancel, Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted":

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と即時キャンセル":

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達不能な RefCounted と遅延キャンセル":

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return)
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_return, Cancel.deferred())
			assert(t.is_completed)
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel)
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_immediate_cancel, Cancel.deferred())
			assert(t.is_canceled)
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_return, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel)
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.canceled())
			assert(t.is_canceled)
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		if true:
			var l := Scope.new()
			t = Task.completed().then_callback(l.then_callback_deferred_cancel, Cancel.deferred())
			assert(t.is_pending)
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%ThenCallback.button_pressed = true

func test_then_callback_name() -> void:
	var g: Scope
	var t: Task

	if "到達可能な RefCounted":

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait() == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait() == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait() == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と即時キャンセル":

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.canceled()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.canceled()) == null)
		assert(t.is_canceled)

	if "到達可能な RefCounted と遅延キャンセル":

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return")
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_return", Cancel.deferred())
		assert(t.is_completed)
		await wait_defer()
		assert(t.is_completed)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel")
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_immediate_cancel", Cancel.deferred())
		assert(t.is_canceled)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == Scope.RETURN)
		assert(t.is_completed)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_return", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel")
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.canceled())
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

		g = Scope.new(); t = Task.completed().then_callback_name(g, &"then_callback_deferred_cancel", Cancel.deferred())
		assert(t.is_pending)
		await wait_defer()
		assert(t.is_canceled)
		assert(await t.wait(Cancel.deferred()) == null)
		assert(t.is_canceled)

	%ThenCallbackName.button_pressed = true

func test_unwrap() -> void:
	var t: Task
	var u: Task
	
	t = Task.completed(Scope.ARG1).unwrap(1)
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Scope.ARG1).unwrap(1, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Scope.ARG1).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Scope.ARG1).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(1)
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(1, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(2)
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(2, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(2, Cancel.deferred())
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Scope.ARG1)).unwrap(2, Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	assert(await t.wait() == Scope.ARG1)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Task.completed(Scope.ARG1))).unwrap(1)
	assert(t.is_completed)
	u = await t.wait()
	assert(u is Task)
	assert(u.is_completed)
	assert(await u.wait() == Scope.ARG1)
	assert(u.is_completed)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Task.completed(Scope.ARG1))).unwrap(1, Cancel.canceled())
	assert(t.is_canceled)
	u = await t.wait()
	assert(u == null)
	assert(t.is_canceled)

	t = Task.completed(Task.completed(Task.completed(Scope.ARG1))).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	u = await t.wait()
	assert(u is Task)
	assert(u.is_completed)
	assert(await u.wait() == Scope.ARG1)
	assert(u.is_completed)
	assert(t.is_completed)

	t = Task.completed(Task.completed(Task.completed(Scope.ARG1))).unwrap(1, Cancel.deferred())
	assert(t.is_completed)
	await wait_defer()
	assert(t.is_completed)
	u = await t.wait()
	assert(u is Task)
	assert(u.is_completed)
	assert(await u.wait() == Scope.ARG1)
	assert(u.is_completed)
	assert(t.is_completed)

	t = Task.canceled().unwrap(1)
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.canceled().unwrap(1, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.canceled().unwrap(1, Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.canceled().unwrap(1, Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(1)
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(1, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(1, Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(1, Cancel.deferred())
	assert(t.is_canceled)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(2)
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(2, Cancel.canceled())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(2, Cancel.deferred())
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	t = Task.completed(Task.canceled()).unwrap(2, Cancel.deferred())
	assert(t.is_canceled)
	await wait_defer()
	assert(t.is_canceled)
	assert(await t.wait() == null)
	assert(t.is_canceled)

	%Unwrap.button_pressed = true

#-------------------------------------------------------------------------------

var _test_array: Array[Callable] = [
	# 1.0.0
	test_completed,
	test_canceled,
	test_never,
	test_from,
	test_from_method,
	test_from_method_name,
	test_from_callback,
	test_from_callback_name,
	test_from_signal,
	test_from_signal_name,
	test_from_conditional_signal,
	test_from_conditional_signal_name,

	test_all,
	test_all_settled,
	test_any,
	test_race,
	test_defer,
	test_defer_process,
	test_defer_physics,
	test_defer_process_frame,
	test_defer_physics_frame,
	test_delay,
	test_delay_msec,
	test_delay_usec,

	test_then,
	test_then_method,
	test_then_method_name,
	test_then_callback,
	test_then_callback_name,
	test_unwrap,
]

var _samples: Array[Dictionary] = []
var _requested_samples: int

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

	for i: int in _test_array.size():
		%Status.text = "テストを実行中... (%d/%d)" % [i + 1, _test_array.size()]
		await _test_array[i].call()
	%Status.text = "全てのテストを通過。"

func _process(delta: float) -> void:
	_samples.push_back({
		"origin": "local",
		"delta": delta,
	})

	_requested_samples -= 1
	if _requested_samples <= 0:
		set_process(false)

func _physics_process(delta: float) -> void:
	_samples.push_back({
		"origin": "local",
		"delta": delta,
	})

	_requested_samples -= 1
	if _requested_samples <= 0:
		set_physics_process(false)
