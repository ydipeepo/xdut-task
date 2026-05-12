## It is a class that holds a state indicating whether cancellation has been requested,
## and is used to request the interruption of the [Task].
@abstract
class_name Cancel

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

## Represents a placeholder for omitting filter matches.
## Used in [method from_filtered_signal] and [method from_filtered_signal_name].
const SKIP: Object = preload("uid://h5d5lq37w8xf")

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

## Emits when cancellation is requested.
signal requested

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Creates a [Cancel] that's requested.
static func canceled() -> Cancel:
	return preload("uid://bsdobpeu7yvx4").create()

## Returns an [Array] containing [Cancel] and [Callable] to request it.
## [codeblock]
## var opers = Cancel.with_operators()
## # opers[0] is Cancel
## # opers[1] is Callable for request
##
## # ...
##
## opers[1].call()
##
## # ...
## [/codeblock]
static func with_operators() -> Array:
	return preload("uid://bnflow2f1f7si").create()

## Creates a [Cancel] from the specified signal defined on an object.
## [codeblock]
## signal s
##
## var c = Cancel.from_signal_name(self, &"s")
## assert(not c.is_requested())
## s.emit()
## assert(c.is_requested())
## [/codeblock]
## [b]Note:[/b] This [Cancel] holds a strong reference to the [param object] until it is requested.
static func from_signal_name(object: Object, signal_name := &"completed") -> Cancel:
	return preload("uid://l85v06xkgrgj").create(object, signal_name)

## Creates a [Cancel] from the specified signal.
## [codeblock]
## signal s
##
## var c = Cancel.from_signal(s)
## assert(not c.is_requested())
## s.emit()
## assert(c.is_requested())
## [/codeblock]
static func from_signal(signal_: Signal) -> Cancel:
	return preload("uid://ctiex620tibef").create(signal_)

## Creates a [Cancel] from the specified signal defined on an object with the arguments filter.
## It is another interface of [method from_filtered_signal_name], not a vararg [param filter_args].
static func from_filtered_signal_name_v(object: Object, signal_name: StringName, filter_args: Array) -> Cancel:
	return preload("uid://bub3cmd8nxibq").create(object, signal_name, filter_args)

## Creates a [Cancel] from the specified signal defined on an object with the arguments filter.
## [codeblock]
## signal s(a, b)
##
## var c = Cancel.from_filtered_signal_name(self, &"s", 78, true)
## s.emit(45, true)
## assert(not c.is_requested())
## s.emit(78, true)
## assert(c.is_requested())
## [/codeblock]
## You can also specify wildcard objects ([member Cancel.SKIP]) in the filter:
## [codeblock]
## signal s(a, b)
##
## var c = Cancel.from_filtered_signal_name(self, &"s", Cancel.SKIP, true)
## s.emit(78, false)
## assert(not c.is_requested())
## s.emit(78, true)
## assert(c.is_requested())
## [/codeblock]
## [b]Note:[/b] This [Cancel] holds a strong reference to the [param object] until it is requested.
static func from_filtered_signal_name(object: Object, signal_name: StringName, ...filter_args: Array) -> Cancel:
	return from_filtered_signal_name_v(object, signal_name, filter_args)

## Creates a [Cancel] from the specified signal with the arguments filter.
## It is another interface of [method from_filtered_signal], not a vararg [param filter_args].
static func from_filtered_signal_v(signal_: Signal, filter_args: Array) -> Cancel:
	return preload("uid://bmknywcx0x54t").create(signal_, filter_args)

## Creates a [Cancel] from the specified signal with the arguments filter.
## [codeblock]
## signal s(a, b)
##
## var c = Cancel.from_filtered_signal(s, 78, true)
## s.emit(45, true)
## assert(not c.is_requested())
## s.emit(78, true)
## assert(c.is_requested())
## [/codeblock]
## You can also specify wildcard objects ([member Cancel.SKIP]) in the filter:
## [codeblock]
## signal s(a, b)
##
## var t = Cancel.from_filtered_signal(s, Cancel.SKIP, true)
## s.emit(78, false)
## assert(not c.is_requested())
## s.emit(78, true)
## assert(c.is_requested())
## [/codeblock]
static func from_filtered_signal(signal_: Signal, ...filter_args: Array) -> Cancel:
	return from_filtered_signal_v(signal_, filter_args)

## Creates a [Cancel] from the specified INIT.
## It is another interface of [method from], not a vararg [param init].
static func from_v(init: Array) -> Cancel:
	return preload("uid://bconh3xtshs17").create(init)

## Creates a [Cancel] from the specified INIT.[br]
## [br]
## [param init] is normalized according to the following rules:
## [codeblock]
## var c
##
## #
## # The following conversions are supported.
## # Lower items have lower priority.
## #
##
## # Dispatches from_filtered_signal_name,
## # if a signal is defined.
## c = Cancel.from(Object, String|StringName, Array)
##
## # Dispatches from_signal_name,
## # if a method is defined.
## c = Cancel.from(Object, String|StringName)
##
## # Dispatches from_filtered_signal.
## c = Cancel.from(Signal, Array)
##
## # Dispatches from_signal,
## # if a signal is defined.
## c = Cancel.from(Signal)
##
## # Wraps specified Cancel.
## c = Cancel.from(Cancel)
##
## # Dispatches from_signal_name,
## # if a 'completed' signal is defined.
## c = Cancel.from(Object)
##
## # Dispatches canceled.
## c = Cancel.from()
## [/codeblock]
static func from(...init: Array) -> Cancel:
	return from_v(init)

## Creates a [Cancel] that requests upon timeout.
static func timeout(timeout_: float, ignore_pause := false, ignore_time_scale := false) -> Cancel:
	return preload("uid://d3u8y2qpll7io").create(timeout_, ignore_pause, ignore_time_scale)

## Creates a [Cancel] that requests at the end of this processing or physics frame.
static func deferred() -> Cancel:
	return preload("uid://8e88hxdgbwum").create()

## Creates a [Cancel] that requests when any INIT requests.
## It is another interface of [method merged], not a vararg [param init_array].
static func merged_v(init_array: Array) -> Cancel:
	return preload("uid://cda587qvy7bi5").create(init_array)

## Creates a [Cancel] that requests when any INIT requests.
## [codeblock]
## var c = Cancel.merged(
##     Cancel.canceled(),
##     Cancel.deferred(),
##     Cancel.timeout(1.0))
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func merged(...init_array: Array) -> Cancel:
	return merged_v(init_array)

## Returns whether this [Cancel] is requesting cancellation.
@abstract
func is_requested() -> bool

## Returns the name of this [Cancel].
@abstract
func get_name() -> StringName

#-------------------------------------------------------------------------------

func _to_string() -> String:
	const AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")

	var prefix := AUTOLOAD_CLASS.get_message(
		&"CANCEL_STATE_REQUESTED"
		if is_requested() else
		&"CANCEL_STATE_PENDING")
	return &"%s<%s#%d>" % [
		prefix,
		get_name(),
		get_instance_id(),
	]
