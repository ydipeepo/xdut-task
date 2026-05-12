extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Task.canceled") -> Task:
	#
	# タスク作成
	#

	return new(name)

func get_name() -> StringName:
	return _name

func get_state() -> int:
	return STATE_CANCELED

@warning_ignore("unused_parameter")
func wait(cancel: Cancel = null) -> Variant:
	return null

#-------------------------------------------------------------------------------

var _name: StringName

func _init(name: StringName) -> void:
	_name = name
