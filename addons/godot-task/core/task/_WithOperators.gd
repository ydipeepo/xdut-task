extends CustomTask

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Task.with_operators") -> Array:
	var task := new(name)
	return [task, task.release_complete, task.release_cancel]

func finalize() -> void:
	pass
