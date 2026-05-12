class_name Cancel_From extends Test

class Callsite:

	signal completed

	var requested_count := 0

	func on_requested() -> void:
		requested_count += 1

func 状態遷移() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(Cancel.deferred())
	if not is_instance_of_type(cancel, _FROM_CLASS):
		return
	cancel.requested.connect(callsite.on_requested)
	is_false(cancel.is_requested())
	are_equal(0, callsite.requested_count)
	await wait_defer()
	is_true(cancel.is_requested())
	are_equal(1, callsite.requested_count)

func 状態遷移_キャンセルあり_即時() -> void:
	var cancel := Cancel.from(Cancel.canceled())
	if not is_instance_of_type(cancel, _CANCELED_CLASS):
		return
	is_true(cancel.is_requested())

func 状態遷移_キャンセルあり_遅延() -> void:
	var cancel := Cancel.from(Cancel.deferred())
	if not is_instance_of_type(cancel, _FROM_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_filtered_signal_name() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite, callsite.completed.get_name(), [])
	if not is_instance_of_type(cancel, _FROM_FILTERED_SIGNAL_NAME_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_filtered_signal() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite.completed, [])
	if not is_instance_of_type(cancel, _FROM_FILTERED_SIGNAL_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_signal_name() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite)
	if not is_instance_of_type(cancel, _FROM_SIGNAL_NAME_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_signal_name_名前指定あり() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite, callsite.completed.get_name())
	if not is_instance_of_type(cancel, _FROM_SIGNAL_NAME_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_signal_name_名前指定あり_空() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite, &"")
	if not is_instance_of_type(cancel, _CANCELED_CLASS):
		return
	is_true(cancel.is_requested())

func ディスパッチ先_from_signal_name_名前指定あり_未定義() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite, &"UNDEFINED")
	if not is_instance_of_type(cancel, _CANCELED_CLASS):
		return
	is_true(cancel.is_requested())

func ディスパッチ先_from_signal() -> void:
	var callsite := Callsite.new()
	var cancel := Cancel.from(callsite.completed)
	if not is_instance_of_type(cancel, _FROM_SIGNAL_CLASS):
		return
	is_false(cancel.is_requested())

func ディスパッチ先_from_signal_空() -> void:
	var cancel := Cancel.from(Signal())
	if not is_instance_of_type(cancel, _CANCELED_CLASS):
		return
	is_true(cancel.is_requested())

func ディスパッチ先_canceled() -> void:
	var cancel := Cancel.from()
	if not is_instance_of_type(cancel, _CANCELED_CLASS):
		return
	is_true(cancel.is_requested())

func スコープ() -> void:
	var cancel: Cancel
	if "scope":
		var callsite := Callsite.new()
		cancel = Cancel.from(callsite.completed)
		if not is_instance_of_type(cancel, _FROM_SIGNAL_CLASS):
			return
		is_false(cancel.is_requested())
		are_equal(1, callsite.get_reference_count())
	is_false(cancel.is_requested())
	await wait_delay(0.1)
	is_true(cancel.is_requested())

const _CANCELED_CLASS := preload("res://addons/godot-task/core/cancel/_Canceled.gd")
const _FROM_FILTERED_SIGNAL_NAME_CLASS := preload("res://addons/godot-task/core/cancel/_FromFilteredSignalName.gd")
const _FROM_FILTERED_SIGNAL_CLASS := preload("res://addons/godot-task/core/cancel/_FromFilteredSignal.gd")
const _FROM_SIGNAL_NAME_CLASS := preload("res://addons/godot-task/core/cancel/_FromSignalName.gd")
const _FROM_SIGNAL_CLASS := preload("res://addons/godot-task/core/cancel/_FromSignal.gd")
const _FROM_CLASS := preload("res://addons/godot-task/core/cancel/_From.gd")
