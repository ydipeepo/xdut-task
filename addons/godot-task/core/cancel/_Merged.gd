extends CustomCancel

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func create(init_array: Array, name := &"Cancel.merged") -> Cancel:
	#
	# 事前チェック
	#

	match init_array.size():
		0:
			_AUTOLOAD_CLASS.print_error(&"EMPTY_INIT_ARRAY")
			return _CANCELED_CLASS.create(name)
		1:
			return _FROM_CLASS.create(init_array.front(), name)
	var cancel_array: Array[Cancel] = []
	for init: Variant in init_array:
		var cancel := _FROM_CLASS.create(init)
		if cancel.is_requested():
			return _CANCELED_CLASS.create(name)
		cancel_array.push_back(cancel)

	#
	# キャンセル作成
	#

	return new(cancel_array)

func finalize() -> void:
	for cancel: Cancel in _cancel_array:
		cancel.requested.disconnect(request)
	_cancel_array.clear()

#-------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://bsdobpeu7yvx4")
const _FROM_CLASS := preload("uid://bconh3xtshs17")

var _cancel_array: Array[Cancel]

func _init(cancel_array: Array[Cancel]) -> void:
	_cancel_array = cancel_array

	for cancel: Cancel in _cancel_array:
		cancel.requested.connect(request)
