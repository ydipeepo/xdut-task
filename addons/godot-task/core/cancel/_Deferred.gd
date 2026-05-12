extends CustomCancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Cancel.deferred") -> Cancel:
	#
	# キャンセル作成
	#

	return new(name)

func finalize() -> void:
	pass

#-------------------------------------------------------------------------------

func _init(name: StringName) -> void:
	super(name)

	request.call_deferred()
