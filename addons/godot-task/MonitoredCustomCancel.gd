## Represents an extension point for implementing custom [Cancel]s.
## If there is a possibility of deadlock, derive from [MonitoredCustomCancel].
@abstract
class_name MonitoredCustomCancel extends CustomCancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Returns whether this [MonitoredCustomCancel] is deadlocked.[br]
## [br]
## This method is called periodically until cancellation is requested on this [MonitoredCustomCancel].
## It must be implemented to return [code]true[/code] when it's in a deadlock.
@abstract
func is_indefinitely_pending() -> bool

#-------------------------------------------------------------------------------

func _init(name: StringName) -> void:
	const AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")

	super(name)

	if not AUTOLOAD_CLASS.has_current():
		AUTOLOAD_CLASS.print_error(&"ADDON_NOT_READY")
		request()
		return

	AUTOLOAD_CLASS \
		.get_current() \
		.monitor_cancel(self)
