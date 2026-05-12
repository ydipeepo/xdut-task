extends CustomCancel

#------------------------------------------------------------------------------
#	METHODS
#------------------------------------------------------------------------------

static func create(
	object: Object,
	signal_name: StringName,
	filter_args: Array,
	name := &"Cancel.from_filtered_signal_name") -> Cancel:

	#
	# 事前チェック
	#

	if not is_instance_valid(object):
		_AUTOLOAD_CLASS.print_error(&"BAD_OBJECT")
		return _CANCELED_CLASS.create(name)
	if not object.has_signal(signal_name):
		_AUTOLOAD_CLASS.print_error(&"BAD_SIGNAL_NAME", signal_name)
		return _CANCELED_CLASS.create(name)
	if not _is_valid_signal_name(object, signal_name, filter_args):
		_AUTOLOAD_CLASS.print_error(&"SIGNAL_SIGNATURE_NOT_MATCH", signal_name)
		return _CANCELED_CLASS.create(name)

	#
	# キャンセル作成
	#

	return new(object, signal_name, filter_args, name)

func finalize() -> void:
	_object.disconnect(_signal_name, _on_completed)
	_object = null

#------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://bsdobpeu7yvx4")

var _object: Object
var _signal_name: StringName
var _filter_args: Array

static func _is_valid_signal_name(object: Object, signal_name: StringName, filter_args: Array) -> bool:
	if \
		_AUTOLOAD_CLASS.has_current() and \
		_AUTOLOAD_CLASS.get_current().get_enable_strict_signal_validation():

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

func _init(
	object: Object,
	signal_name: StringName,
	filter_args: Array,
	name: StringName) -> void:

	super(name)

	_signal_name = signal_name
	_filter_args = filter_args
	_object = object
	_object.connect(_signal_name, _on_completed)

@warning_ignore("unused_parameter")
func _on_completed(...args: Array) -> void:
	if args.size() != _filter_args.size():
		_AUTOLOAD_CLASS.print_error(&"SIGNAL_SIGNATURE_NOT_MATCH", _signal_name)
		request()
	elif _match_signal_args(args, _filter_args):
		request()
