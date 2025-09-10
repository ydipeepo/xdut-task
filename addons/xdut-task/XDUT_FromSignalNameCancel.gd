class_name XDUT_FromSignalNameCancel extends XDUT_CancelBase

#------------------------------------------------------------------------------

func _init(
	object: Object,
	signal_name: StringName) -> void:

	super(&"FromSignalNameCancel")
	if not is_instance_valid(object):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_OBJECT"))
		return
	if not object.has_signal(signal_name):
		push_error(internal_task_get_canonical()
			.translate(&"ERROR_BAD_SIGNAL_NAME")
			.format([signal_name]))
		return
	object.connect(signal_name, request, CONNECT_ONE_SHOT)
