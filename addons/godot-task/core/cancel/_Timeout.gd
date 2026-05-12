extends CustomCancel

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const MIN_TIMEOUT := 0.0

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	timeout_: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	name := &"Cancel.timeout") -> Cancel:

	#
	# 事前チェック
	#

	if timeout_ <= MIN_TIMEOUT:
		_AUTOLOAD_CLASS.print_error(&"BAD_TIMEOUT")
		return _CANCELED_CLASS.create(name)
	if timeout_ == MIN_TIMEOUT:
		return _CANCELED_CLASS.create(name)

	#
	# キャンセル作成
	#

	return new(timeout_, ignore_pause, ignore_time_scale, name)

func get_name() -> StringName:
	return _name

func finalize() -> void:
	_timer.timeout.disconnect(request)
	_timer = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://bsdobpeu7yvx4")

var _timer: SceneTreeTimer

func _init(
	timeout_: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	name: StringName) -> void:

	super(name)

	var tree: SceneTree = Engine.get_main_loop()
	_timer = tree.create_timer(timeout_, ignore_pause, false, ignore_time_scale)
	_timer.timeout.connect(request)
