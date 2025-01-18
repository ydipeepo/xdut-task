## 外部から状態遷移に必要な追加のタイミングを与える必要のある [Task] の半実装。
class_name MonitoredTaskBase extends TaskBase

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## 完了できない条件を満たしている場合は真を返すよう実装する必要があります。
func is_indefinitely_pending() -> bool:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return false

#-------------------------------------------------------------------------------

func _init(
	cancel: Cancel,
	name: StringName) -> void:

	super(cancel, name)

	var canonical := get_canonical()
	if canonical == null:
		release_cancel()
		return
	canonical.monitor_deadlock(self)
