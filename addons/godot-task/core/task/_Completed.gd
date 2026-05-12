extends Task

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(result: Variant, name := &"Task.completed") -> Task:
	#
	# タスク作成
	#

	return new(result, name)

func get_name() -> StringName:
	return _name

func get_state() -> int:
	return STATE_COMPLETED

@warning_ignore("unused_parameter")
func wait(cancel: Cancel = null) -> Variant:
	return _result

#-------------------------------------------------------------------------------

var _name: StringName
var _result: Variant

func _init(result: Variant, name: StringName) -> void:
	_name = name
	_result = result
