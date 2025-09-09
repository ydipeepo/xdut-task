class_name XDUT_FromSignalCancel extends XDUT_CancelBase

#------------------------------------------------------------------------------

func _init(signal_: Signal) -> void:
	super(&"FromSignalCancel")

	if not is_instance_valid(signal_.get_object()) or signal_.is_null():
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT_ASSOCIATED_WITH_SIGNAL"))
		return

	signal_.connect(request, CONNECT_ONE_SHOT)
