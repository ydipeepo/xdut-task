extends MonitoredCustomCancel

#------------------------------------------------------------------------------
#	METHODS
#------------------------------------------------------------------------------

static func create(
	signal_: Signal,
	filter_args: Array,
	name := &"Cancel.from_filtered_signal") -> Cancel:

	#
	# 事前チェック
	#

	if not is_instance_valid(signal_.get_object()) or signal_.is_null():
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT_ASSOCIATED_WITH_SIGNAL")
		return _CANCELED_CLASS.create(name)
	if not _is_valid_signal(signal_, filter_args):
		_AUTOLOAD_CLASS.print_error(&"SIGNAL_SIGNATURE_NOT_MATCH", signal_.get_name())
		return _CANCELED_CLASS.create(name)

	#
	# キャンセル作成
	#

	return new(signal_, filter_args, name)

func is_indefinitely_pending() -> bool:
	return not is_instance_valid(_signal.get_object()) or _signal.is_null()

func finalize() -> void:
	if is_instance_valid(_signal.get_object()) and not _signal.is_null():
		_signal.disconnect(_on_completed)

#------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://bsdobpeu7yvx4")

var _filter_args: Array
var _signal: Signal

static func _is_valid_signal(signal_: Signal, filter_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_signal_validation():

		var object := signal_.get_object()
		var signal_name := signal_.get_name()
		var signal_info := _AUTOLOAD_CLASS.get_signal_info(object, signal_name)
		var signal_info_args: Array = signal_info.args
		if signal_info_args.size() != filter_args.size():
			return false
		for index: int in signal_info_args.size():
			var filter_arg: Variant = filter_args[index]
			if filter_arg is Object and filter_arg == SKIP:
				continue
			if typeof(filter_arg) not in _AUTOLOAD_CLASS.VALID_ARG_TYPES_MAP[signal_info_args[index].type]:
				return false
	return true

static func _match_signal_args(args: Array, filter_args: Array) -> bool:
	if args.size() != filter_args.size():
		return false
	for index: int in filter_args.size():
		var arg: Variant = args[index]
		var arg_type := typeof(arg)
		var filter_arg: Variant = filter_args[index]
		var filter_arg_type := typeof(filter_arg)
		match filter_arg_type:
			TYPE_NIL:
				if arg_type != TYPE_NIL:
					return false
			TYPE_STRING, \
			TYPE_STRING_NAME:
				if arg_type != TYPE_STRING and arg_type != TYPE_STRING_NAME or arg != filter_arg:
					return false
			TYPE_OBJECT:
				if filter_arg == SKIP:
					continue
				if arg_type != TYPE_OBJECT or filter_arg != arg:
					return false
			_:
				if not is_same(arg, filter_arg):
					return false
	return true

func _init(signal_: Signal, filter_args: Array, name: StringName) -> void:
	super(name)

	_filter_args = filter_args
	_signal = signal_
	_signal.connect(_on_completed)

@warning_ignore("unused_parameter")
func _on_completed(...args: Array) -> void:
	if args.size() != _filter_args.size():
		_AUTOLOAD_CLASS.print_error(&"SIGNAL_SIGNATURE_NOT_MATCH", _signal.get_name())
		request()
	elif _match_signal_args(args, _filter_args):
		request()
