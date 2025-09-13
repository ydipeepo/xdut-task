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

func translate(translation_key: StringName) -> StringName:
	return _translation_domain.translate(translation_key)

func create_timer(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false) -> SceneTreeTimer:

	return _tree.create_timer(
		timeout,
		ignore_pause,
		false,
		ignore_time_scale)

func monitor_deadlock(task: MonitoredTaskBase) -> void:
	if _deadlock_monitor_enabled:
		if _deadlock_monitor_task_wrefs.is_empty():
			_deadlock_monitor_idle_spin = 0
			_on_monitor_deadlock.call_deferred()
		_deadlock_monitor_task_wrefs.push_back(weakref(task))

#-------------------------------------------------------------------------------

const _TRANSLATION_EN: Dictionary[StringName, String] = {
	&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT": "The antecedent task {0} returned an invalid state! (There is probably an implementation issue.)",
	&"DEBUG_BAD_STATE_RETURNED_BY_INIT": "The {1}-th INIT task {0} returned an invalid state! (There is probably an implementation issue.)",
	&"ERROR_EMPTY_INIT_ARRAY": "INIT array is empty.",
	&"ERROR_BAD_TIMEOUT": "The specified timeout is invalid.",
	&"ERROR_BAD_OBJECT": "The specified object is invalid.",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD": "The object associated with the method is invalid.",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_SIGNAL": "The object associated with the signal is invalid.",
	&"ERROR_BAD_METHOD_NAME": "An invalid method '{0}' was specified.",
	&"ERROR_BAD_METHOD_ARGC": "An invalid argument count {1} was specified for method '{0}'.",
	&"ERROR_BAD_SIGNAL_NAME": "An invalid signal '{0}' was specified.",
	&"ERROR_BAD_SIGNAL_ARGC": "An invalid argument count {1} was specified for signal '{0}'.",
	&"ERROR_BAD_UNWRAP_DEPTH": "The specified unwrap count is invalid.",
	&"ERROR_BAD_RESOURCE_FILE": "Failed to load resource '{0}' ({1}).",
	&"ERROR_BAD_RESOURCE_LOAD": "Some error occurred while loading resource '{0}' ({1}).",
	&"TASK_STATE_PENDING": "(Pending)",
	&"TASK_STATE_PENDING_WITH_WAITERS": "(Pending with waiters)",
	&"TASK_STATE_CANCELED": "(Canceled)",
	&"TASK_STATE_COMPLETED": "(Completed)",
	&"CANCEL_STATE_PENDING": "(Pending)",
	&"CANCEL_STATE_REQUESTED": "(Requested)",
}

const _TRANSLATION_JA: Dictionary[StringName, String] = {
	&"DEBUG_BAD_STATE_RETURNED_BY_ANTECEDENT": "入力したソースタスク {0} が不正な状態を返しました。(実装に問題があります)",
	&"DEBUG_BAD_STATE_RETURNED_BY_INIT": "入力した {1} 番目の INIT タスク {0} が不正な状態を返しました。(実装に問題があります)",
	&"ERROR_EMPTY_INIT_ARRAY": "INIT 配列が空です。",
	&"ERROR_BAD_TIMEOUT": "指定したタイムアウトは無効です。",
	&"ERROR_BAD_OBJECT": "指定したオブジェクトは無効です。",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD": "メソッドに関連付けられているオブジェクトが無効です。",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_SIGNAL": "シグナルに関連付けられているオブジェクトが無効です。",
	&"ERROR_BAD_METHOD_NAME": "不正なメソッド '{0}' を指定しました。",
	&"ERROR_BAD_METHOD_ARGC": "メソッド '{0}' に対し、不正な引数数 {1} を指定しました。",
	&"ERROR_BAD_SIGNAL_NAME": "不正なシグナル '{0}' を指定しました。",
	&"ERROR_BAD_SIGNAL_ARGC": "シグナル '{0}' に対し、不正な引数数 {1} を指定しました。",
	&"ERROR_BAD_UNWRAP_DEPTH": "指定したアンラップ回数は無効です。",
	&"ERROR_BAD_RESOURCE_FILE": "リソース '{0}' ({1}) の読み込みに失敗しました。",
	&"ERROR_BAD_RESOURCE_LOAD": "リソース '{0}' ({1}) の読み込み中に何らかのエラーが発生しました。",
	&"TASK_STATE_PENDING": "(未決定)",
	&"TASK_STATE_PENDING_WITH_WAITERS": "(未決定、待機有り)",
	&"TASK_STATE_CANCELED": "(キャンセル)",
	&"TASK_STATE_COMPLETED": "(完了)",
	&"CANCEL_STATE_PENDING": "(未決定)",
	&"CANCEL_STATE_REQUESTED": "(要求済み)",
}

var _tree: MainLoop
var _translation_domain := TranslationDomain.new()
var _deadlock_monitor_enabled: bool
var _deadlock_monitor_max_idle_spin: int
var _deadlock_monitor_force_cancel_when_addon_exit_tree: bool
var _deadlock_monitor_idle_spin: int
var _deadlock_monitor_task_wrefs: Array[WeakRef] = []

func _add_translation(
	locale: StringName,
	translation_map: Dictionary[StringName, String]) -> void:

	var translation := Translation.new()
	translation.locale = locale
	for translation_key: StringName in translation_map:
		translation.add_message(translation_key, translation_map[translation_key])

	_translation_domain.add_translation(translation)

func _process(delta: float) -> void:
	process.emit(delta)

func _physics_process(delta: float) -> void:
	physics.emit(delta)

func _enter_tree() -> void:
	_add_translation(&"en", _TRANSLATION_EN)
	_add_translation(&"ja", _TRANSLATION_JA)

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
					var task: MonitoredTaskBase = task_wref.get_ref()
					if task != null:
						task.release_cancel_with_cleanup()
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
		var task: MonitoredTaskBase = task_wref.get_ref()
		if task == null:
			_deadlock_monitor_task_wrefs[index] = null
			index += 1
			continue
		if task.is_indefinitely_pending():
			_deadlock_monitor_task_wrefs[index] = null
			task.release_cancel()
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
