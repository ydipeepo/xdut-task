extends CustomCancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(name := &"Cancel.with_operators") -> Array:
	var cancel := new(name)
	return [cancel, cancel.request]

func finalize() -> void:
	pass
