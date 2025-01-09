class_name XDUT_DeferredCancel extends XDUT_CancelBase

#-------------------------------------------------------------------------------

func _init() -> void:
	super(&"DeferredCancel")
	request.call_deferred()
