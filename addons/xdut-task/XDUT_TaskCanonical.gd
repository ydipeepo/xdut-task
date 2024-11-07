#-------------------------------------------------------------------------------
#
#
#	Copyright 2022-2024 Ydi (@ydipeepo.bsky.social)
#
#
#	Permission is hereby granted, free of charge, to any person obtaining
#	a copy of this software and associated documentation files (the "Software"),
#	to deal in the Software without restriction, including without limitation
#	the rights to use, copy, modify, merge, publish, distribute, sublicense,
#	and/or sell copies of the Software, and to permit persons to whom
#	the Software is furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#	OTHER DEALINGS IN THE SOFTWARE.
#
#
#-------------------------------------------------------------------------------

extends Node

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

signal process(delta: float)
signal physics(delta: float)
signal process_frame(delta: float)
signal physics_frame(delta: float)

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func create_timer(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false) -> SceneTreeTimer:

	return _tree.create_timer(
		timeout,
		ignore_pause,
		false,
		ignore_time_scale)

func monitor_deadlock(task: XDUT_TaskBase) -> void:
	if _deadlock_monitor_enabled:
		if _deadlock_monitor_task_wrefs.is_empty():
			_deadlock_monitor_idle_spin = 0
			_on_monitor_deadlock.call_deferred()
		_deadlock_monitor_task_wrefs.push_back(weakref(task))

#-------------------------------------------------------------------------------

var _tree: MainLoop
var _deadlock_monitor_enabled: bool
var _deadlock_monitor_max_idle_spin: int
var _deadlock_monitor_force_cancel_when_addon_exit_tree: bool
var _deadlock_monitor_idle_spin: int
var _deadlock_monitor_task_wrefs: Array[WeakRef] = []

func _process(delta: float) -> void:
	process.emit(delta)

func _physics_process(delta: float) -> void:
	physics.emit(delta)

func _enter_tree() -> void:
	_deadlock_monitor_enabled = ProjectSettings.get_setting("xdut/task/deadlock_monitor/enabled", true)
	_deadlock_monitor_max_idle_spin = ProjectSettings.get_setting("xdut/task/deadlock_monitor/max_idle_spin", 3)
	_deadlock_monitor_force_cancel_when_addon_exit_tree = ProjectSettings.get_setting("xdut/task/deadlock_monitor/force_cancel_when_addon_exit_tree", false)

	_tree = Engine.get_main_loop()
	_tree.process_frame.connect(_on_process_frame)
	_tree.physics_frame.connect(_on_physics_frame)

func _exit_tree() -> void:
	_tree.process_frame.disconnect(_on_process_frame)
	_tree.physics_frame.disconnect(_on_physics_frame)
	_tree = null

	if _deadlock_monitor_force_cancel_when_addon_exit_tree:
		if _deadlock_monitor_task_wrefs.is_empty():
			for task_wref: WeakRef in _deadlock_monitor_task_wrefs:
				if task_wref != null:
					var task: XDUT_TaskBase = task_wref.get_ref()
					if task != null:
						task.on_orphaned()
			_deadlock_monitor_task_wrefs.clear()

func _on_process_frame() -> void:
	if not _deadlock_monitor_task_wrefs.is_empty():
		_deadlock_monitor_idle_spin = 0
		_on_monitor_deadlock()

	process_frame.emit(get_process_delta_time())

func _on_physics_frame() -> void:
	physics_frame.emit(get_physics_process_delta_time())

func _on_monitor_deadlock() -> void:
	var index := 0
	var count := 0
	while index < _deadlock_monitor_task_wrefs.size():
		var task_wref := _deadlock_monitor_task_wrefs[index]
		if task_wref == null:
			index += 1
			continue
		var task: XDUT_TaskBase = task_wref.get_ref()
		if task == null:
			_deadlock_monitor_task_wrefs[index] = null
			index += 1
			continue
		if task.is_indefinitely_pending():
			_deadlock_monitor_task_wrefs[index] = null
			task.release_cancel_with_cleanup()
			index += 1
			continue
		index += 1
		count += 1

	if count == 0:
		_deadlock_monitor_task_wrefs.clear()
	else:
		_deadlock_monitor_idle_spin += 1
		if _deadlock_monitor_idle_spin < _deadlock_monitor_max_idle_spin:
			_on_monitor_deadlock.call_deferred()
