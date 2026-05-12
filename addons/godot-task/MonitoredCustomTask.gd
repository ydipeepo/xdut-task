## Represents an extension point for implementing custom [Task]s.
## If there is a possibility of deadlock, derive from [MonitoredCustomTask].
@abstract
class_name MonitoredCustomTask extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Returns whether this [MonitoredCustomTask] is deadlocked.[br]
## [br]
## This method is called periodically until this [MonitoredCustomTask] is settled (either completed or canceled).
## It must be implemented to return [code]true[/code] when it's in a deadlock.
@abstract
func is_indefinitely_pending() -> bool

#-------------------------------------------------------------------------------

func _init(name: StringName) -> void:
	const AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")

	super(name)

	if not AUTOLOAD_CLASS.has_current():
		AUTOLOAD_CLASS.print_error(&"ADDON_NOT_READY")
		release_cancel()
		return

	AUTOLOAD_CLASS \
		.get_current() \
		.monitor_task(self)
