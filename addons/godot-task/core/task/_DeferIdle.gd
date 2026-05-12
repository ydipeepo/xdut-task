extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Task.defer_idle") -> Task:
	#
	# 事前チェック
	#

	if not _AUTOLOAD_CLASS.has_current():
		_AUTOLOAD_CLASS.print_error(&"ADDON_NOT_READY")
		return _CANCELED_CLASS.create(name)

	#
	# タスク作成
	#

	return new(name)

func finalize() -> void:
	_AUTOLOAD_CLASS \
		.get_current() \
		.idle \
		.disconnect(release_complete)

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://cs53oltrhgj3q")

func _init(name: StringName) -> void:
	super(name)

	_AUTOLOAD_CLASS \
		.get_current() \
		.idle \
		.connect(release_complete)
