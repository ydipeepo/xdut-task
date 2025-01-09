class_name XDUT_CancelBase extends Cancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func get_canonical() -> Node:
	if not is_instance_valid(_canonical):
		_canonical = Engine \
			.get_main_loop() \
			.root \
			.get_node("/root/XDUT_TaskCanonical")
	return _canonical

func get_requested() -> bool:
	return _requested

func request() -> void:
	if not _requested:
		_requested = true
		requested.emit()

#-------------------------------------------------------------------------------

static var _canonical: Node

var _name: StringName
var _requested := false

func _init(name: StringName) -> void:
	_name = name

func _to_string() -> String:
	var str: String
	match get_requested():
		false:
			str = "(pending)"
		true:
			str = "(requested)"
	return "%s<%s#%d>" % [str, _name, get_instance_id()]
