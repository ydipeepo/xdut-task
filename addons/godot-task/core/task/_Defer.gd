extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Task.defer") -> Task:
	#
	# タスク作成
	#

	return new(name)

func finalize() -> void:
	pass

#-------------------------------------------------------------------------------

func _init(name: StringName) -> void:
	super(name)

	release_complete.call_deferred()
