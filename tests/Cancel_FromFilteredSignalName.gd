class_name Cancel_FromFilteredSignalName extends Test

class Callsite:

	signal completed

	signal completed_params(a: int, b: int)

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移_名前指定あり_未定義() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_filtered_signal_name(callsite, &"UNDEFINED")
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_名前指定あり_未定義_フィルタ() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_filtered_signal_name(callsite, &"UNDEFINED", Cancel.SKIP, 78)
	if not is_not_null(cancel):
		return
	is_true(cancel.is_requested())

func 状態遷移_名前指定あり() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_filtered_signal_name(callsite, callsite.completed.get_name())
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)
	callsite.completed.emit()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_名前指定あり_フィルタ() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from_filtered_signal_name(callsite, callsite.completed_params.get_name(), Cancel.SKIP, 78)
	if not is_not_null(cancel):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed_params.emit(45, 12)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	callsite.completed_params.emit(45, 78)
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)
	callsite.completed_params.emit(45, 78)
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func スコープ_名前指定あり() -> void:
	var callsite := Callsite.new()
	if "scope":
		var cancel := Cancel.from_filtered_signal_name(callsite, callsite.completed.get_name())
		if not is_not_null(cancel):
			return
		is_false(cancel.is_requested()); are_equal(2, callsite.get_reference_count())
		callsite.completed.emit()
		is_true(cancel.is_requested()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())

func スコープ_名前指定あり_フィルタ() -> void:
	var callsite := Callsite.new()
	if "scope":
		var cancel := Cancel.from_filtered_signal_name(callsite, callsite.completed_params.get_name(), Cancel.SKIP, 78)
		if not is_not_null(cancel):
			return
		is_false(cancel.is_requested()); are_equal(2, callsite.get_reference_count())
		callsite.completed_params.emit(45, 12)
		is_false(cancel.is_requested()); are_equal(2, callsite.get_reference_count())
		callsite.completed_params.emit(45, 78)
		is_true(cancel.is_requested()); are_equal(1, callsite.get_reference_count())
	are_equal(1, callsite.get_reference_count())
