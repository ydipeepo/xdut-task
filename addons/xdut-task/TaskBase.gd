## 入力のみで完結する [Task] の半実装。
class_name TaskBase extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_state() -> int:
	return _state

func wait(cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if not is_instance_valid(cancel) or cancel.requested.is_connected(release_cancel):
			while await _release != null: pass
		elif not cancel.is_requested:
			cancel.requested.connect(release_cancel)
			while await _release != null: pass
			cancel.requested.disconnect(release_cancel)
		else:
			release_cancel()
	return _result

## [method wait_temporary] により解放されるか、この [Task] の結果が決まるまで一時的に待機します。
func wait_temporary(object: Object, cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if not is_instance_valid(cancel) or cancel.requested.is_connected(release_cancel):
			while true:
				var sender: Object = await _release
				if sender == null or sender == object: break
		elif not cancel.is_requested:
			cancel.requested.connect(release_cancel)
			while true:
				var sender: Object = await _release
				if sender == null or sender == object: break
			cancel.requested.disconnect(release_cancel)
		else:
			release_cancel()
	return _result

## 全ての一時的な待機を解放します。[br]
## [br]
## 入力に複数の [Task] を受け取る実装において入力に対し副作用を与えずに[br]
## 待機を解放するためのメソッドです。この呼び出しでは状態遷移は発生しません。[br]
## 引数には呼び出し元の [Task] など、より長期の寿命を持ったオブジェクトを指定します。[br]
## このオブジェクトは入力が他の [Task] への入力と重複する場合、[br]
## [method wait_temporary] による一時的な待機をマスクします。
func release(object: Object) -> void:
	match _state:
		STATE_PENDING_WITH_WAITERS:
			_release.emit(object)

## 待機中であれば、完了状態に遷移させ全ての待機を解放します。
func release_complete(result: Variant = null) -> void:
	match _state:
		STATE_PENDING:
			_result = result
			_state = STATE_COMPLETED
			cleanup()
		STATE_PENDING_WITH_WAITERS:
			_result = result
			_state = STATE_COMPLETED
			cleanup()
			_release.emit(null)

## 待機中であれば、キャンセルされた状態に遷移させ全ての待機を解放します。
func release_cancel() -> void:
	match _state:
		STATE_PENDING:
			_state = STATE_CANCELED
			cleanup()
		STATE_PENDING_WITH_WAITERS:
			_state = STATE_CANCELED
			cleanup()
			_release.emit(null)

## 追加のクリーンアップ処理を実装します。[br]
## [br]
## 解放前に一度だけ XDUT Task から呼び出されます。[br]
## [br]
## ❗ 直接呼び出してはいけません。
func cleanup() -> void:
	if _indigenous_cancel != null:
		if _indigenous_cancel.requested.is_connected(release_cancel):
			_indigenous_cancel.requested.disconnect(release_cancel)
		_indigenous_cancel = null

#-------------------------------------------------------------------------------

signal _release(object: Object)

var _name: StringName
var _state: int = STATE_PENDING
var _result: Variant
var _indigenous_cancel: Cancel

func _init(cancel: Cancel, name := &"TaskBase") -> void:
	assert(not name.is_empty())
	_name = name

	if cancel != null:
		assert(not cancel.is_requested)
		_indigenous_cancel = cancel
		_indigenous_cancel.requested.connect(release_cancel)

func _to_string() -> String:
	var prefix: String
	match get_state():
		STATE_PENDING:
			prefix = internal_get_task_canonical() \
				.translate(&"TASK_STATE_PENDING")
		STATE_PENDING_WITH_WAITERS:
			prefix = internal_get_task_canonical() \
				.translate(&"TASK_STATE_PENDING_WITH_WAITERS")
		STATE_CANCELED:
			prefix = internal_get_task_canonical() \
				.translate(&"TASK_STATE_CANCELED")
		STATE_COMPLETED:
			prefix = internal_get_task_canonical() \
				.translate(&"TASK_STATE_COMPLETED")
		_:
			assert(false)
	return &"%s<%s#%d>" % [prefix, _name, get_instance_id()]
