class_name Cancel_Canceled extends Test

func 状態遷移() -> void:
	var cancel := Cancel.canceled()
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())
