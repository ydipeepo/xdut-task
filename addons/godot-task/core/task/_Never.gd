extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Task.never") -> Task:
	#
	# タスク作成
	#

	return new(name)

func get_name() -> StringName:
	return _name

func get_state() -> int:
	return _state

func wait(cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if not is_instance_valid(cancel) or cancel.requested.is_connected(release_cancel):
			await _release
		elif not cancel.is_requested():
			cancel.requested.connect(release_cancel)
			await _release
			cancel.requested.disconnect(release_cancel)
		else:
			release_cancel()
	return null

func release_cancel() -> void:
	match _state:
		STATE_PENDING:
			_state = STATE_CANCELED
		STATE_PENDING_WITH_WAITERS:
			_state = STATE_CANCELED
			_release.emit()

#-------------------------------------------------------------------------------

signal _release

var _name: StringName
var _state: int = STATE_PENDING

func _init(name: StringName) -> void:
	_name = name
