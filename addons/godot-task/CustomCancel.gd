## Represents an extension point for implementing custom [Cancel]s.
## Generally, you should derive from [CustomCancel], or
## from [MonitoredCustomCancel] if there is a possibility of deadlock.
@abstract
class_name CustomCancel extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Returns whether this [Cancel] is requesting cancellation.
## It is the implementation of [method Cancel.is_requested].
func is_requested() -> bool:
	return _requested

## Returns the name of this [Cancel].
## It is the implementation of [method Cancel.get_name].
func get_name() -> StringName:
	return _name

## Requests cancellation on this [Cancel].
func request() -> void:
	if not _requested:
		_requested = true
		requested.emit()
		finalize()

## This method is called for perform cleanup processing when cancellation is requested.[br]
## [br]
## For example, it implements cleanup processes such as releasing resources or disconnecting signals, etc.
## And it is called only once per [CustomCancel] instance. So you [b]MUST NOT[/b] call it directly.
@abstract
func finalize() -> void

#-------------------------------------------------------------------------------

var _name: StringName
var _requested: bool

func _init(name: StringName) -> void:
	_name = name
