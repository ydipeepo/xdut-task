class_name Cancel_FromSignalName extends Test

class Callsite:

	signal completed

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal_name(callsite)
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal_name(callsite, callsite.completed.get_name())
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_名前指定あり_デフォルト() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal_name(callsite)
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_名前指定あり_空() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal_name(callsite, &"")
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_名前指定あり_未定義() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_signal_name(callsite, &"UNDEFINED")
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_無効なコールサイト() -> void:
	var cancel := Cancel.from_signal_name(null)
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_無効なコールサイト_名前指定あり_空() -> void:
	var cancel := Cancel.from_signal_name(null, &"")
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_無効なコールサイト_名前指定あり_未定義() -> void:
	var cancel := Cancel.from_signal_name(null, &"UNDEFINED")
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())
