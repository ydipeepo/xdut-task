extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Cancel.canceled") -> Cancel:
	#
	# キャンセル作成
	#

	return new(name)

func is_requested() -> bool:
	return true

func get_name() -> StringName:
	return _name

#-------------------------------------------------------------------------------

var _name: StringName

func _init(name: StringName) -> void:
	_name = name
