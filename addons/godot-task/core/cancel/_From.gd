extends CustomCancel

#------------------------------------------------------------------------------
#	METHODS
#------------------------------------------------------------------------------

static func create(init: Variant, name := &"Cancel.from") -> Cancel:
	if init is Array:
		match init.size():
			3 when init[0] is Object and (init[1] is String or init[1] is StringName):
				if init[0].has_signal(init[1]):
					if init[2] is Array:
						return _FROM_FILTERED_SIGNAL_NAME_CLASS.create(
							init[0],
							init[1],
							init[2],
							name)
			2 when init[0] is Object and (init[1] is String or init[1] is StringName):
				return _FROM_SIGNAL_NAME_CLASS.create(init[0], init[1], name)
			2 when init[0] is Signal:
				if init[1] is Array:
					return _FROM_FILTERED_SIGNAL_CLASS.create(
						init[0],
						init[1],
						name)
			1 when init[0] is Signal:
				return _FROM_SIGNAL_CLASS.create(init[0], name)
			1 when init[0] is Object:
				if init[0] is Cancel:
					return \
						_CANCELED_CLASS.create(name) \
						if init[0].is_requested() else \
						new(init[0], name)
				else:
					return _FROM_SIGNAL_NAME_CLASS.create(
						init[0],
						&"completed",
						name)
	if init is Signal:
		return _FROM_SIGNAL_CLASS.create(init, name)
	if init is Object:
		if init is Cancel:
			return \
				_CANCELED_CLASS.create(name) \
				if init.is_requested() else \
				new(init, name)
		else:
			return _FROM_SIGNAL_NAME_CLASS.create(init, &"completed", name)

	_AUTOLOAD_CLASS.print_error(&"BAD_INIT")
	return _CANCELED_CLASS.create(name)

func finalize() -> void:
	if _cancel.requested.is_connected(request):
		_cancel.requested.disconnect(request)
	_cancel = null

#------------------------------------------------------------------------------

const _AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")
const _CANCELED_CLASS := preload("uid://bsdobpeu7yvx4")
const _FROM_FILTERED_SIGNAL_CLASS := preload("uid://bmknywcx0x54t")
const _FROM_FILTERED_SIGNAL_NAME_CLASS := preload("uid://bub3cmd8nxibq")
const _FROM_SIGNAL_CLASS := preload("uid://ctiex620tibef")
const _FROM_SIGNAL_NAME_CLASS := preload("uid://l85v06xkgrgj")

var _cancel: Cancel

func _init(cancel: Cancel, name: StringName) -> void:
	super(name)

	_cancel = cancel
	_cancel.requested.connect(request)
