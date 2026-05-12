## Represents an extension point for implementing custom [Task]s.
## Generally, you should derive from [CustomTask], or
## from [MonitoredCustomTask] if there is a possibility of deadlock.
@abstract
class_name CustomTask extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Returns the name of this [Task].
## It is the implementation of [method Task.get_name].
func get_name() -> StringName:
	return _name

## Returns the status of this [Task].
## It is the implementation of [method Task.get_state].
func get_state() -> int:
	return _state

## Returns [Cancel] for cascade.[br]
## [br]
## Specify this cancellation when a cancellation needs to be cascaded to the input [Task].
## It is synchronized with the cancellation of this [Task].
func get_cascade_cancel() -> Cancel:
	if _cascade.is_empty():
		_cascade = Cancel.with_operators()
	return _cascade[0]

## Waits until this [Task] is settled (either completed or canceled).
## It is the implementation of [method Task.wait].[br]
## [br]
## [b]Note:[/b] Calling [method release_complete] or [method release_cancel] is only valid once.
func wait(cancel: Cancel = null) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		if not is_instance_valid(cancel) or cancel.requested.is_connected(release_cancel):
			while await _release != null: pass
		elif not cancel.is_requested():
			cancel.requested.connect(release_cancel)
			while await _release != null: pass
			cancel.requested.disconnect(release_cancel)
		else:
			release_cancel()
	return _result

## Sets the result and transitions to the completed state then releasing any blocked [method Task.wait] callers.[br]
## [br]
## [b]Note:[/b] Calling [method release_complete] or [method release_cancel] is only valid once.
func release_complete(result: Variant = null) -> void:
	match _state:
		STATE_PENDING:
			_result = result
			_state = STATE_COMPLETED
			if not _cascade.is_empty():
				_cascade[1].call()
			finalize()
		STATE_PENDING_WITH_WAITERS:
			_result = result
			_state = STATE_COMPLETED
			if not _cascade.is_empty():
				_cascade[1].call()
			finalize()
			_release.emit(null)

## Transitions to the canceled state then releases any blocked [method Task.wait] callers.
func release_cancel() -> void:
	match _state:
		STATE_PENDING:
			_state = STATE_CANCELED
			if not _cascade.is_empty():
				_cascade[1].call()
			finalize()
		STATE_PENDING_WITH_WAITERS:
			_state = STATE_CANCELED
			if not _cascade.is_empty():
				_cascade[1].call()
			finalize()
			_release.emit(null)

## When waiting for other [CustomTask], please call this method instead of [method Task.wait].
## [method temporary_wait] waits like the [method Task.wait] but does not have side effects on that [CustomTask].
## [codeblock]
## var result: Variant
## if task is CustomTask:
##     result = await task.temporary_wait(self)
## else:
##     result = await task.wait(cascade_cancel)
## [/codeblock]
## [b]Note:[/b] If you call [method temporary_wait], you must also call [method temporary_release] as a pair.
func temporary_wait(object: Object) -> Variant:
	if _state == STATE_PENDING:
		_state = STATE_PENDING_WITH_WAITERS
	if _state == STATE_PENDING_WITH_WAITERS:
		while true:
			var source: Object = await _release
			if source == null or source == object: break
	return _result

## Releases the wait caused by the [method temporary_wait] method.
## [codeblock]
## if task is CustomTask:
##     task.temporary_release(self)
## [/codeblock]
## [b]Note:[/b] If you call [method temporary_wait], you must also call [method temporary_release] as a pair.
func temporary_release(object: Object) -> void:
	match _state:
		STATE_PENDING_WITH_WAITERS:
			_release.emit(object)

## This method is called for perform cleanup processing when the state is settled (either completed or canceled).[br]
## [br]
## For example, it implements cleanup processes such as releasing resources or disconnecting signals, etc.
## And it is called only once per [CustomTask] instance. So you [b]MUST NOT[/b] call it directly.
@abstract
func finalize() -> void

#-------------------------------------------------------------------------------

signal _release(object: Object)

var _name: StringName
var _state: int = STATE_PENDING
var _result: Variant
var _cascade: Array

func _init(name: StringName) -> void:
	_name = name
