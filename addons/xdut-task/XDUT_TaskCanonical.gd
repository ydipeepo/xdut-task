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
	&"TASK_STATE_PENDING": "(pending)",
	&"TASK_STATE_PENDING_WITH_WAITERS": "(pending with waiters)",
	&"TASK_STATE_CANCELED": "(canceled)",
	&"TASK_STATE_COMPLETED": "(completed)",
	&"CANCEL_STATE_PENDING": "(pending)",
	&"CANCEL_STATE_REQUESTED": "(requested)",
	&"ERROR_BAD_STATE": "Bad state: input ({0})",
	&"ERROR_BAD_STATE_WITH_ORDINAL": "Bad state: inputs[{1}] ({0})",
	&"ERROR_BAD_TIMEOUT": "Bad timeout.",
	&"ERROR_BAD_OBJECT": "Bad object.",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD": "Invalid object associated with method.",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_SIGNAL": "Invalid object associated with signal.",
	&"ERROR_BAD_METHOD_NAME": "Bad method name: {0}",
	&"ERROR_BAD_METHOD_ARGC": "Bad method argument count: {0} ({1})",
	&"ERROR_BAD_SIGNAL_NAME": "Bad signal name: {0}",
	&"ERROR_BAD_SIGNAL_ARGC": "Bad signal argument count: {0} ({1})",
	&"ERROR_BAD_UNWRAP_DEPTH": "Invalid depth.",
	&"WARNING_BAD_INPUTS": "Invalid inputs.",
	&"ERROR_BAD_RESOURCE": "Failed to load due to reached invalid resource: {0}",
	&"ERROR_BAD_RESOURCE_INTERNAL": "Failed to load due to some error occurred: {0}",
}

const _TRANSLATION_JA: Dictionary[StringName, String] = {
	&"TASK_STATE_PENDING": "(未決定)",
	&"TASK_STATE_PENDING_WITH_WAITERS": "(未決定、待機有り)",
	&"TASK_STATE_CANCELED": "(キャンセル)",
	&"TASK_STATE_COMPLETED": "(完了)",
	&"CANCEL_STATE_PENDING": "(未決定)",
	&"CANCEL_STATE_REQUESTED": "(要求済み)",
	&"ERROR_BAD_STATE": "無効な状態: input ({0})",
	&"ERROR_BAD_STATE_WITH_ORDINAL": "無効な状態: inputs[{1}] ({0})",
	&"ERROR_BAD_TIMEOUT": "無効なタイムアウト。",
	&"ERROR_BAD_OBJECT": "無効なオブジェクト。",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_METHOD": "メソッドに関連付けられている無効なオブジェクト。",
	&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_SIGNAL": "シグナルに関連付けられている無効なオブジェクト。",
	&"ERROR_BAD_METHOD_NAME": "無効なメソッド名: {0}",
	&"ERROR_BAD_METHOD_ARGC": "無効なメソッド引数数: {0} ({1})",
	&"ERROR_BAD_SIGNAL_NAME": "無効なシグナル名: {0}",
	&"ERROR_BAD_SIGNAL_ARGC": "無効なシグナル引数数: {0} ({1})",
	&"ERROR_BAD_UNWRAP_DEPTH": "無効なアンラップ数。",
	&"WARNING_BAD_INPUTS": "無効な入力。",
	&"ERROR_BAD_RESOURCE": "リソースの読み込みに失敗: {0}",
	&"ERROR_BAD_RESOURCE_LOADER": "リソースの読み込み中に何らかのエラーが発生しました: {0}",
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

func _ready() -> void:
	_add_translation(&"en", _TRANSLATION_EN)
	_add_translation(&"ja", _TRANSLATION_JA)

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
