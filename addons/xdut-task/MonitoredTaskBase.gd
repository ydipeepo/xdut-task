## 外部から状態遷移に必要な追加のタイミングを与える必要のある [Task] の半実装。
@abstract
class_name MonitoredTaskBase extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## 完了できない条件を満たしている場合は真を返すよう実装する必要があります。
@abstract
func is_indefinitely_pending() -> bool

#-------------------------------------------------------------------------------

func _init(cancel: Cancel, name: StringName) -> void:
	super(cancel, name)
	internal_get_task_canonical() \
		.monitor_deadlock(self)
