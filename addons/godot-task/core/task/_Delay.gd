extends CustomTask

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

const MIN_TIMEOUT := 0.0

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	name := &"Task.delay") -> Task:

	#
	# 事前チェック
	#

	if timeout < MIN_TIMEOUT:
		_AUTOLOAD_CLASS.print_error(&"BAD_TIMEOUT")
		return _CANCELED_CLASS.create(name)
	if timeout == MIN_TIMEOUT:
		return _COMPLETED_CLASS.create(MIN_TIMEOUT, name)

	#
	# タスク作成
	#

	return new(timeout, ignore_pause, ignore_time_scale, name)

func finalize() -> void:
	_timer \
		.timeout \
		.disconnect(release_complete)
	_timer = null

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _COMPLETED_CLASS := preload("uid://cxtfk6753t3x5")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

var _timer: SceneTreeTimer

func _init(
	timeout: float,
	ignore_pause: bool,
	ignore_time_scale: bool,
	name: StringName) -> void:

	super(name)

	var tree: SceneTree = Engine.get_main_loop()
	_timer = tree.create_timer(timeout, ignore_pause, false, ignore_time_scale)
	_timer \
		.timeout \
		.connect(release_complete.bind(timeout))
