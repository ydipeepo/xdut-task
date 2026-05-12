## Represents the cancellation or completion of an asynchronous operation and its resulting value.
##
## [Task] is a proxy for a value that may not be known at the time of its creation.
## It is a class that can link the completion of a signal or coroutine with a result or failure.
## This allows signals or coroutines to return values in the same way as synchronous methods,
## by returning a [Task] that will provide the value at some future point,
## instead of returning the result value directly.

@abstract
class_name Task extends Awaitable

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

## Represents a state waiting for a result.
const STATE_PENDING := 0

## Represents a state waiting for a result,
## with one or more calls blocked by [method wait].
const STATE_PENDING_WITH_WAITERS := 1

## Represents a completed state. The state will no longer change.
const STATE_COMPLETED := 2

## Represents a canceled state. The state will no longer change.
const STATE_CANCELED := 3

## Represents a placeholder for omitting filter matches.
## Used in [method from_filtered_signal] and [method from_filtered_signal_name].
const SKIP: Object = preload("uid://d2va1f1opsrlq")

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Creates a [Task] that's completed with the specified result.
## [codeblock]
## var t = Task.completed(123)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
static func completed(result: Variant = null) -> Task:
	return preload("uid://cxtfk6753t3x5").create(result)

## Creates a [Task] that's canceled.
## [codeblock]
## var t = Task.canceled()
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
static func canceled() -> Task:
	return preload("uid://cs53oltrhgj3q").create()

## Creates a [Task] that's neither completed nor canceled.
## [codeblock]
## var t = Task.never()
## assert(t.is_pending())
## [/codeblock]
## [b]Note:[/b] It can only be canceled by passing [Cancel].
static func never() -> Task:
	return preload("uid://dnj148hmipgia").create()

## Returns an [Array] containing [Task] and [Callable] to complete it,
## and [Callable] to cancel it.
## [codeblock]
## var opers = Task.with_operators()
## # opers[0] is Task
## # opers[1] is Callable for complete
## # opers[2] is Callable for cancel
##
## # ...
##
## opers[1].call()
##
## # ...
## [/codeblock]
## You can also optionally specify the result:
## [codeblock]
## # ...
##
## opers[1].call(123)
## [/codeblock]
static func with_operators() -> Array:
	return preload("uid://cgvk8ffourjr8").create()

## Creates a [Task] from the specified method defined on an object.
## [codeblock]
## func f():
##     return 123
##
## var t = Task.from_method_name(self, &"f")
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) as an 1st argument for cancellation:
## [codeblock]
## func f(cancel: Callable):
##     cancel.call()
##     return 123
##
## var t = Task.from_method_name(self, &"f")
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_method_name(object: Object, method_name := &"wait") -> Task:
	return preload("uid://dy8sicj8lrg8y").create(object, method_name)

## Creates a [Task] from the specified method.
## [codeblock]
## func f():
##     return 123
##
## var t = Task.from_method(f)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) as an 1st argument for cancellation:
## [codeblock]
## func f(cancel: Callable):
##     cancel.call()
##     return 123
##
## var t = Task.from_method(f)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
static func from_method(method: Callable) -> Task:
	return preload("uid://dxdjtx2f1e176").create(method)

## Creates a [Task] from the specified method defined on an object with the arguments binding.
## It is another interface of [method from_bound_method_name], not a vararg [param bind_args].[br]
## [br]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_bound_method_name_v(object: Object, method_name: StringName, bind_args: Array) -> Task:
	return preload("uid://0qyj5d0p0hoo").create(object, method_name, bind_args)

## Creates a [Task] from the specified method defined on an object with the arguments binding.
## [codeblock]
## func f(a, b):
##     return a + b
##
## var t = Task.from_bound_method_name(self, &"f", 45, 78)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) as an 1st argument for cancellation:
## [codeblock]
## func f(a, b, cancel: Callable):
##     cancel.call()
##     return a + b
##
## var t = Task.from_bound_method_name(self, &"f", 45, 78)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_bound_method_name(object: Object, method_name: StringName, ...bind_args: Array) -> Task:
	return from_bound_method_name_v(object, method_name, bind_args)

## Creates a [Task] from the specified method with the arguments binding.
## It is another interface of [method from_bound_method], not a vararg [param bind_args].
static func from_bound_method_v(method: Callable, bind_args: Array) -> Task:
	return preload("uid://cw5fbusiiwqmv").create(method, bind_args)

## Creates a [Task] from the specified method with the arguments binding.
## [codeblock]
## func f(a, b):
##     return a + b
##
## var t = Task.from_bound_method(f, 45, 78)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) as an 1st argument for cancellation:
## [codeblock]
## func f(a, b, cancel: Callable):
##     cancel.call()
##     return a + b
##
## var t = Task.from_bound_method(f, 45, 78)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
static func from_bound_method(method: Callable, ...bind_args: Array) -> Task:
	return from_bound_method_v(method, bind_args)

## Creates a [Task] from the specified signal defined on an object.
## [codeblock]
## signal s
##
## var t = Task.from_signal_name(self, &"s")
## s.emit()
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [])
## [/codeblock]
## You can also specify a signal that take arguments:
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_signal_name(self, &"s")
## s.emit(45, 78)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [45, 78])
## [/codeblock]
## The result of this [Task] will be an [Array] containing the signal arguments.[br]
## [br]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_signal_name(object: Object, signal_name := &"completed") -> Task:
	return preload("uid://bcixwy06v8s6n").create(object, signal_name)

## Creates a [Task] from the specified signal.
## [codeblock]
## signal s
##
## var t = Task.from_signal(s)
## s.emit()
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [])
## [/codeblock]
## You can also specify a signal that take arguments:
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_signal(t)
## s.emit(45, 78)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [45, 78])
## [/codeblock]
## The result of this [Task] will be an [Array] containing the signal arguments.
static func from_signal(signal_: Signal) -> Task:
	return preload("uid://dcuyxx4r6qafe").create(signal_)

## Creates a [Task] from the specified signal defined on an object with the arguments filter.
## It is another interface of [method from_filtered_signal_name], not a vararg [param filter_args].[br]
## [br]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_filtered_signal_name_v(object: Object, signal_name: StringName, filter_args: Array) -> Task:
	return preload("uid://bvyq3bu45benl").create(object, signal_name, filter_args)

## Creates a [Task] from the specified signal defined on an object with the arguments filter.
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_filtered_signal_name(self, &"s", 78, true)
## s.emit(45, true)
## s.emit(78, true)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [78, true])
## [/codeblock]
## You can also specify wildcard objects ([member Task.SKIP]) in the filter:
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_filtered_signal_name(self, &"s", Task.SKIP, true)
## s.emit(78, false)
## s.emit(78, true)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [78, true])
## [/codeblock]
## The result of this [Task] will be an [Array] containing the signal arguments.[br]
## [br]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
static func from_filtered_signal_name(object: Object, signal_name: StringName, ...filter_args: Array) -> Task:
	return from_filtered_signal_name_v(object, signal_name, filter_args)

## Creates a [Task] from the specified signal with the arguments filter.
## It is another interface of [method from_filtered_signal], not a vararg [param filter_args].
static func from_filtered_signal_v(signal_: Signal, filter_args: Array) -> Task:
	return preload("uid://coguo2lmcq4vl").create(signal_, filter_args)

## Creates a [Task] from the specified signal with the arguments filter.
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_filtered_signal(s, 78, true)
## s.emit(45, true)
## s.emit(78, true)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [78, true])
## [/codeblock]
## You can also specify wildcard objects ([member Task.SKIP]) in the filter:
## [codeblock]
## signal s(a, b)
##
## var t = Task.from_filtered_signal(s, Task.SKIP, true)
## s.emit(78, false)
## s.emit(78, true)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [78, true])
## [/codeblock]
## [br]
## The result of this [Task] will be an [Array] containing the signal arguments.
static func from_filtered_signal(signal_: Signal, ...filter_args: Array) -> Task:
	return from_filtered_signal_v(signal_, filter_args)

## Creates a [Task] from the specified INIT.
## It is another interface of [method from], not a vararg [param init].
static func from_v(init: Variant) -> Task:
	return preload("uid://dy6eonb15bmuf").create(init)

## Creates a [Task] from the specified INIT.[br]
## [br]
## [param init] is normalized according to the following rules:
## [codeblock]
## var t
##
## #
## # The following conversions are supported.
## # Lower items have lower priority.
## #
##
## # Dispatches from_bound_method_name,
## # if a method is defined.
## t = Task.from(Object, String|StringName, Array)
##
## # Dispatches from_filtered_signal_name,
## # if a signal is defined.
## t = Task.from(Object, String|StringName, Array)
##
## # Dispatches from_method_name,
## # if a method is defined.
## t = Task.from(Object, String|StringName)
##
## # Dispatches from_signal_name,
## # if a signal is defined.
## t = Task.from(Object, String|StringName)
##
## # Dispatches from_bound_method_name.
## t = Task.from(Callable, Array)
##
## # Dispatches from_filtered_signal.
## t = Task.from(Signal, Array)
##
## # Wraps specified Task.
## t = Task.from(Task)
##
## # Dispatches from_method_name,
## # if a 'wait' method is defined.
## t = Task.from(Object)
##
## # Dispatches from_signal_name,
## # if a 'completed' signal is defined.
## t = Task.from(Object)
##
## # Dispatches from_method.
## t = Task.from(Callable)
##
## # Dispatches from_signal.
## t = Task.from(Signal)
##
## # Dispatches completed.
## t = Task.from(Variant)
## [/codeblock]
static func from(...init: Array) -> Task:
	return from_v(init)

## Creates a continuation [Task] from the specified method defined on a object that executes asynchronously when this [Task] completes.
## [codeblock]
## func f():
##     return 123
##
## var t = Task \
##     .completed() \
##     .then_method_name(self, &"f")
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also receive the previous results:
## [codeblock]
## func f(result):
##     return result + 78
##
## var t = Task \
##     .completed(45) \
##     .then_method_name(self, &"f")
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) for cancellation:
## [codeblock]
## func f(result, cancel: Callable):
##     cancel.call()
##     return result + 78
##
## var t = Task \
##     .completed(45) \
##     .then_method_name(self, &"f")
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
func then_method_name(object: Object, method_name: StringName) -> Task:
	return preload("uid://cn048monfibu6").create(self, object, method_name)

## Creates a continuation [Task] from the specified method that executes asynchronously when this [Task] completes.
## [codeblock]
## func f():
##     return 123
##
## var t = Task \
##     .completed() \
##     .then_method(f)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also receive the previous results:
## [codeblock]
## func f(result):
##     return result + 78
##
## var t = Task \
##     .completed(45) \
##     .then_method(f)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) for cancellation:
## [codeblock]
## func f(result, cancel: Callable):
##     cancel.call()
##     return result + 78
##
## var t = Task \
##     .completed(45) \
##     .then_method(f)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
func then_method(method: Callable) -> Task:
	return preload("uid://ca3x3abwsp84v").create(self, method)

## Creates a continuation [Task] from the specified method defined on a object
## with the arguments binding that executes asynchronously when this [Task] completes.
## It is another interface of [method then_bound_method_name], not a vararg [param init_array].[br]
## [br]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
func then_bound_method_name_v(object: Object, method_name: StringName, bind_args: Array) -> Task:
	return preload("uid://b3n8qgb5m1eoa").create(self, object, method_name, bind_args)

## Creates a continuation [Task] from the specified method defined on a object
## with the arguments binding that executes asynchronously when this [Task] completes.
## [codeblock]
## func f(a, b):
##     return a + b + 3
##
## var t = Task \
##     .completed() \
##     .then_bound_method_name(self, &"f", 100, 20)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also receive the previous results:
## [codeblock]
## func f(a, b, result):
##     return a + b + result
##
## var t = Task \
##     .completed(3) \
##     .then_bound_method_name(self, &"f", 100, 20)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) for cancellation:
## [codeblock]
## func f(a, b, result, cancel: Callable):
##     cancel.call()
##     return a + b + result
##
## var t = Task \
##     .completed(3) \
##     .then_bound_method_name(self, &"f", 100, 20)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
## [b]Note:[/b] This [Task] holds a strong reference to the [param object] until it is completed or canceled.
func then_bound_method_name(object: Object, method_name: StringName, ...bind_args: Array) -> Task:
	return then_bound_method_name_v(object, method_name, bind_args)

## Creates a continuation [Task] from the specified method with the arguments binding that
## executes asynchronously when this [Task] completes.
## It is another interface of [method then_bound_method], not a vararg [param init_array].
func then_bound_method_v(method: Callable, bind_args: Array) -> Task:
	return preload("uid://q2b0bc8iovj").create(self, method, bind_args)

## Creates a continuation [Task] from the specified method with the arguments binding that
## executes asynchronously when this [Task] completes.
## [codeblock]
## func f(a, b):
##     return a + b + 3
##
## var t = Task \
##     .completed() \
##     .then_bound_method(f, 100, 20)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also receive the previous results:
## [codeblock]
## func f(a, b, result):
##     return a + b + result
##
## var t = Task \
##     .completed(3) \
##     .then_bound_method(f, 100, 20)
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
## You can also specify a method that takes a [Callable] (not [Cancel]) for cancellation:
## [codeblock]
## func f(a, b, result, cancel: Callable):
##     cancel.call()
##     return a + b + result
##
## var t = Task \
##     .completed(3) \
##     .then_bound_method(f, 100, 20)
## var r = await t.wait()
## assert(t.is_canceled())
## assert(r == null)
## [/codeblock]
func then_bound_method(method: Callable, ...bind_args: Array) -> Task:
	return then_bound_method_v(method, bind_args)

## Creates a continuation [Task] from the specified INIT
## that executes asynchronously when this [Task] completes.
## It is another interface of [method then], not a vararg [param init].
func then_v(init: Variant) -> Task:
	return preload("uid://cd3h5kvw2d3j1").create(self, init)

## Creates a continuation [Task] from the specified INIT
## that executes asynchronously when this [Task] completes.[br]
## [br]
## [param init] is normalized according to the following rules:
## [codeblock]
## var t
##
## #
## # The following conversions are supported.
## # Lower items have lower priority.
## #
##
## # Dispatches then_bound_method_name,
## # if a method is defined.
## t = Task.completed().then(Object, String|StringName, Array)
##
## # Dispatches then_method_name,
## # if a method is defined,
## t = Task.completed().then(Object, String|StringName)
##
## # Dispatches then_bound_method_name.
## t = Task.completed().then(Callable, Array)
##
## # Wraps the specified Task for continuation.
## t = Task.completed().then(Task)
##
## # Dispatches then_method_name,
## # if a 'wait' method is defined,
## t = Task.completed().then(Object)
##
## # Dispatches then_method.
## t = Task.completed().then(Callable)
##
## # Wraps the specified value for continuation.
## t = Task.completed().then(Variant)
## [/codeblock]
func then(...init: Array) -> Task:
	return then_v(init)

## Creates a [Task] that completes when all INITs complete and cancels when any INIT cancels.
## It is another interface of [method all], not a vararg [param init_array].
static func all_v(init_array: Array) -> Task:
	return preload("uid://cnxd2vb5dp1kc").create(init_array)

## Creates a [Task] that completes when all INITs complete and cancels when any INIT cancels.[br]
## [br]
## If [param init_array] is empty, this [Task] will have an empty [Array] set as its result and complete.
## When all INITs complete, this [Task] will have an [Array] containing each INIT's result set as its result and complete.
## When any INIT cancels, this [Task] will be canceled.
## [codeblock]
## var t = Task.all(
##     Task.completed(1),
##     2,
##     Task.delay(1.0).then(func(): return 3))
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == [1, 2, 3])
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func all(...init_array: Array) -> Task:
	return all_v(init_array)

## Creates a [Task] that completes when all INITs are settled (either completed or canceled).
## It is another interface of [method all_settled], not a vararg [param init_array].
static func all_settled_v(init_array: Array) -> Task:
	return preload("uid://brrblia7tdcdh").create(init_array)

## Creates a [Task] that completes when all INITs are settled (either completed or canceled).[br]
## [br]
## If [param init_array] is empty, this [Task] will have an empty [Array] set as its result and complete.
## When all INITs complete or are canceled, this [Task] will have an [Array] containing each INIT set as its result and complete.
## [codeblock]
## var t = Task.all_settled(
##     Task.completed(1),
##     2,
##     Task.canceled())
## var r = await t.wait()
## assert(t.is_completed())
## assert(r[0] is Task and r[0].is_completed() and await r[0].wait() == 1)
## assert(r[1] is Task and r[1].is_completed() and await r[1].wait() == 2)
## assert(r[2] is Task and r[2].is_canceled())
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func all_settled(...init_array: Array) -> Task:
	return all_settled_v(init_array)

## Creates a [Task] that completes when any INIT completes, and cancels when all INITs cancel.
## It is another interface of [method any], not a vararg [param init_array].
static func any_v(init_array: Array) -> Task:
	return preload("uid://lpwvjqgnxuht").create(init_array)

## Creates a [Task] that completes when any INIT completes, and cancels when all INITs cancel.[br]
## [br]
## If [param init_array] is empty, this [Task] will be canceled.
## When any INIT completes, this [Task] will have the INIT's result set as its result and complete.
## When all INITs cancel, this [Task] will be canceled.
## [codeblock]
## var t = Task.any(
##     Task.delay(0.5),
##     Task.delay(1.0),
##     Task.delay(1.5))
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 0.5)
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func any(...init_array: Array) -> Task:
	return any_v(init_array)

## Creates a [Task] that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and cancels when any INIT is canceled.
## It is another interface of [method race], not a vararg [param init_array].
static func race_v(init_array: Array) -> Task:
	return preload("uid://cmi00b5f5yllh").create(init_array)

## Creates a [Task] that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and cancels when any INIT is canceled.[br]
## [br]
## If [param init_array] is empty, this [Task] will remain pending.
## When any INIT completes or is canceled, this [Task] will have the INIT set as its result and complete.
## [codeblock]
## var t = Task.race(
##     Task.delay(0.5),
##     Task.delay(1.0),
##     Task.delay(1.5))
## var r = await t.wait()
## assert(t.is_completed())
## assert(r is Task and r.is_completed() and await r.wait() == 0.5)
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func race(...init_array: Array) -> Task:
	return race_v(init_array)

## Creates a [Task] that completes when all INITs are settled (either completed or canceled).
## This is a variant of the [method all_settled_v] method, where the result is the number of completed INITs.
## It is another interface of [method count], not a vararg [param init_array].
static func count_v(init_array: Array) -> Task:
	return preload("uid://b75nn4js3751i").create(init_array)

## Creates a [Task] that completes when all INITs are settled (either completed or canceled).
## This is a variant of the [method all_settled] method, where the result is the number of completed INITs.[br]
## [br]
## If [param init_array] is empty, this [Task] will have [code]0[/code] set as its result and complete.
## When all INITs complete or are canceled, this [Task] will have the number of completed INITs set as its result and complete.
## [codeblock]
## var t = Task.count(
##     Task.completed(1),
##     Task.delay(1.0),
##     Task.canceled())
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 2)
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func count(...init_array: Array) -> Task:
	return count_v(init_array)

## Creates a [Task] that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and is canceled if any INIT is canceled.
## This is a variant of the [method race_v] method, where the result is the index of the first completed INIT.
## It is another interface of [method index], not a vararg [param init_array].
static func index_v(init_array: Array) -> Task:
	return preload("uid://n2jvnobx3ut2").create(init_array)

## Creates a [Task] that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and is canceled if any INIT is canceled.
## This is a variant of the [method race] method, where the result is the index of the first completed INIT.[br]
## [br]
## If [param init_array] is empty, this [Task] will be canceled.
## When any INIT completes, this [Task] will have the INIT's index set as its result and complete.
## When all INITs cancel, this [Task] will be canceled.
## [codeblock]
## var t = Task.index(
##     Task.delay(1.5),
##     Task.completed(),
##     Task.delay(1.5))
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 1)
## [/codeblock]
## [b]Note:[/b] INIT (each component of [param init_array]) will be normalized according to the [method from] rule.
static func index(...init_array: Array) -> Task:
	return index_v(init_array)

## Creates a [Task] that will complete after a time delay.[br]
## [br]
## [param timeout] will be the result of this [Task].
static func delay(timeout: float, ignore_pause := false, ignore_time_scale := false) -> Task:
	return preload("uid://bppd7tb4n1byo").create(timeout, ignore_pause, ignore_time_scale)

## Creates a [Task] that waits until the idle time is reached.
static func defer() -> Task:
	return preload("uid://blnmsxbc1sf0s").create()

## Creates a [Task] that waits until the next idle frame start.[br]
## [br]
## [method Node.get_process_delta_time] will be the result of this [Task].
static func defer_idle_frame() -> Task:
	return preload("uid://b2ucefd0wgybp").create()

## Creates a [Task] that waits until the next idle frame end.[br]
## [br]
## [method Node.get_process_delta_time] will be the result of this [Task].
static func defer_idle() -> Task:
	return preload("uid://yk0efk6nma17").create()

## Creates a [Task] that waits until the next physics frame start.[br]
## [br]
## [method Node.get_physics_process_delta_time] will be the result of this [Task].
static func defer_physics_frame() -> Task:
	return preload("uid://g360wy8jd2rd").create()

## Creates a [Task] that waits until the next physics frame end.[br]
## [br]
## [method Node.get_physics_process_delta_time] will be the result of this [Task].
static func defer_physics() -> Task:
	return preload("uid://bf0sk3v7efpkv").create()

## Creates a [Task] to unwrap the results.
## [codeblock]
## var t = Task \
##     .completed(Task.completed(123)) \
##     .unwrap()
## var r = await t.wait()
## assert(t.is_completed())
## assert(r == 123)
## [/codeblock]
func unwrap(depth := 1) -> Task:
	return preload("uid://dwir0mp1m53qc").create(self, depth)

## Creates a [Task] to load the resource.[br]
## [br]
## This [Task] will complete upon successful loading.
## It will be canceled if any error occurs.
## [codeblock]
## var t = Task.load("res://MyScene.tscn", &"PackedScene")
## var r = await Task.wait()
## if t.is_completed():
##     var s = r.instantiate()
##     add_child(s)
## [/codeblock]
static func load(resource_path: String, resource_type: StringName, cache_mode := ResourceLoader.CACHE_MODE_IGNORE) -> Task:
	return preload("uid://bphmwv25grocp").create(resource_path, resource_type, cache_mode)

## Creates a [Task] to underlying HTTP GET request.[br]
## [br]
## This [Task] will complete upon successful requesting.
## It will be canceled if any error occurs.
## [codeblock]
## var t = Task.http_get("https://http.codes/200", [], 1.0)
## var r = await t.wait()
## if t.is_completed():
##     print(r.body.get_string_from_utf8())
## [/codeblock]
static func http_get(url: String, headers: PackedStringArray = [], timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_GET,
		url,
		headers,
		"",
		timeout,
		&"Task.http_get")

## Creates a [Task] to underlying HTTP HEAD request.
## For details, please read [method http_get].
static func http_head(url: String, headers: PackedStringArray = [], timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_HEAD,
		url,
		headers,
		"",
		timeout,
		&"Task.http_head")

## Creates a [Task] to underlying HTTP POST request.
## For details, please read [method http_get].
static func http_post(url: String, headers: PackedStringArray = [], body := "", timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_POST,
		url,
		headers,
		body,
		timeout,
		&"Task.http_post")

## Creates a [Task] to underlying HTTP PUT request.
## For details, please read [method http_get].
static func http_put(url: String, headers: PackedStringArray = [], body := "", timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_PUT,
		url,
		headers,
		body,
		timeout,
		&"Task.http_put")

## Creates a [Task] to underlying HTTP DELETE request.
## For details, please read [method http_get].
static func http_delete(url: String, headers: PackedStringArray = [], body := "", timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_DELETE,
		url,
		headers,
		body,
		timeout,
		&"Task.http_delete")

## Creates a [Task] to underlying HTTP OPTIONS request.
## For details, please read [method http_get].
static func http_options(url: String, headers: PackedStringArray = [], body := "", timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_OPTIONS,
		url,
		headers,
		body,
		timeout,
		&"Task.http_options")

## Creates a [Task] to underlying HTTP PATCH request.
## For details, please read [method http_get].
static func http_patch(url: String, headers: PackedStringArray = [], body := "", timeout := 0.0) -> Task:
	const HTTP_CLASS := preload("uid://brinc67lpo30a")
	return HTTP_CLASS.create(
		HTTP_CLASS.METHOD_PATCH,
		url,
		headers,
		body,
		timeout,
		&"Task.http_patch")

## Waits that completes when all INITs complete and cancels when any INIT cancels.
## For details, please read [method all].
## [codeblock]
## var r = await Task.wait_all_v([
##     Task.completed(1),
##     2,
##     Task.delay(1.0).then(func(): return 3),
## ])
## assert(r == [1, 2, 3])
## [/codeblock]
static func wait_all_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await all_v(init_array).wait(cancel)

## Waits that completes when all INITs are settled (either completed or canceled).
## For details, please read [method all_settled].
## [codeblock]
## var r = await Task.wait_all_settled_v([
##     Task.completed(1),
##     2,
##     Task.canceled(),
## ])
## assert(r[0] is Task and r[0].is_completed() and await r[0].wait() == 1)
## assert(r[1] is Task and r[1].is_completed() and await r[1].wait() == 2)
## assert(r[2] is Task and r[2].is_canceled())
## [/codeblock]
static func wait_all_settled_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await all_settled_v(init_array).wait(cancel)

## Waits that completes when any INIT completes, and cancels when all INITs cancel.
## For details, please read [method any].
## [codeblock]
## var r = await Task.wait_any_v([
##     Task.delay(0.5),
##     Task.delay(1.0),
##     Task.delay(1.5),
## ])
## assert(r == 0.5)
## [/codeblock]
static func wait_any_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await any_v(init_array).wait(cancel)

## Waits that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and cancels when any INIT is canceled.
## For details, please read [method race].
## [codeblock]
## var r = await Task.wait_race_v([
##     Task.delay(0.5),
##     Task.delay(1.0),
##     Task.delay(1.5),
## ])
## assert(r is Task and r.is_completed() and await r.wait() == 0.5)
## [/codeblock]
static func wait_race_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await race_v(init_array).wait(cancel)

## Waits that completes when all INITs are settled (either completed or canceled).
## This is a variant of the [method wait_all_settled_v] method, where the result is the number of completed INITs.
## [codeblock]
## var r = await Task.wait_count_v([
##     Task.completed(1),
##     Task.delay(1.0),
##     Task.canceled(),
## ])
## assert(r == 2)
## [/codeblock]
static func wait_count_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await count_v(init_array).wait(cancel)

## Waits that completes when any INIT is settled (either completed or canceled).
## That is, it completes when any INIT is settled, and is canceled if any INIT is canceled.
## This is a variant of the [method wait_race_v] method, where the result is the index of the first completed INIT.
## [codeblock]
## var r = await Task.wait_index_v([
##     Task.delay(1.5),
##     Task.completed(),
##     Task.delay(1.5),
## ])
## assert(r == 1)
## [/codeblock]
static func wait_index_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await index_v(init_array).wait(cancel)

## Waits that will complete after a time delay.
## For details, please read [method delay].
static func wait_delay(timeout: float, ignore_pause := false, ignore_time_scale := false, cancel: Cancel = null) -> Variant:
	return await delay(timeout, ignore_pause, ignore_time_scale).wait(cancel)

## Waits until the idle time is reached.
## For details, please read [method defer].
static func wait_defer(cancel: Cancel = null) -> Variant:
	return await defer().wait(cancel)

## Waits until the next idle frame start.
## For details, please read [method defer_process_frame].
static func wait_defer_idle_frame(cancel: Cancel = null) -> Variant:
	return await defer_idle_frame().wait(cancel)

## Waits until the next idle frame end.
## For details, please read [method defer_process].
static func wait_defer_idle(cancel: Cancel = null) -> Variant:
	return await defer_idle().wait(cancel)

## Waits until the next physics frame start.
## For details, please read [method defer_physics_frame].
static func wait_defer_physics_frame(cancel: Cancel = null) -> Variant:
	return await defer_physics_frame().wait(cancel)

## Waits until the next physics frame end.
## For details, please read [method defer_physics].
static func wait_defer_physics(cancel: Cancel = null) -> Variant:
	return await defer_physics().wait(cancel)

## Returns [code]true[/code] if this [Task] is completed,
## otherwise returns [code]false[/code].[br]
## [br]
## [b]Note:[/b] The value returned by this method is equivalent to:
## [method get_state][code] == [/code][constant STATE_COMPLETED]
func is_completed() -> bool:
	return get_state() == STATE_COMPLETED

## Returns [code]true[/code] if this [Task] is canceled,
## otherwise returns [code]false[/code].[br]
## [br]
## [b]Note:[/b] The value returned by this method is equivalent to:
## [method get_state][code] == [/code][constant STATE_CANCELED]
func is_canceled() -> bool:
	return get_state() == STATE_CANCELED

## Returns [code]true[/code] if this [Task] is neither completed nor canceled and is awaiting a result,
## otherwise returns [code]false[/code].[br]
## [br]
## [b]Note:[/b] The value returned by this method is equivalent to:
## [method get_state][code] in [[/code][constant STATE_PENDING][code], [/code][constant STATE_PENDING_WAITERS][code]][/code]
func is_pending() -> bool:
	var state := get_state()
	return \
		state == STATE_PENDING or \
		state == STATE_PENDING_WITH_WAITERS

## Returns the name of this [Task].
@abstract
func get_name() -> StringName

## Returns the status of this [Task].[br]
## [br]
## [b]Note:[/b] You can use the [method is_pending], [method is_completed],
## and [method is_canceled] properties for the same purpose.
@abstract
func get_state() -> int

## Waits until this [Task] is settled (either completed or canceled).
## Returns the result if completed, or [code]null[/code] if canceled.
## [codeblock]
## var t = Task.completed(123)
## var r = await t.wait()
## assert(r == 123)
## [/codeblock]
## You can also interrupt by passing [Cancel].
## [codeblock]
## signal s
##
## var c = Cancel.timeout(1.0)
## var t = Task.from_signal(s)
## var r = await t.wait(c)
## match t.get_state():
##     STATE_COMPLETED:
##         pass
##     STATE_CANCELED:
##         pass
## [/codeblock]
## After [method wait] returns processing, including when interrupted by [Cancel],
## [method get_state] will always be either [constant STATE_COMPLETED] or [constant STATE_CANCELED].
## (And, if it derives [Task], it must be implemented to be so.)[br]
## [br]
## [b]Note:[/b] This method must be called with the [code]await[/code] keyword.
@abstract
func wait(cancel: Cancel = null) -> Variant

#-------------------------------------------------------------------------------

func _to_string() -> String:
	const AUTOLOAD_CLASS := preload("uid://d4ixdr1hdia5t")

	var prefix: String
	match get_state():
		STATE_PENDING:
			prefix = AUTOLOAD_CLASS.get_message(&"TASK_STATE_PENDING")
		STATE_PENDING_WITH_WAITERS:
			prefix = AUTOLOAD_CLASS.get_message(&"TASK_STATE_PENDING_WITH_WAITERS")
		STATE_CANCELED:
			prefix = AUTOLOAD_CLASS.get_message(&"TASK_STATE_CANCELED")
		STATE_COMPLETED:
			prefix = AUTOLOAD_CLASS.get_message(&"TASK_STATE_COMPLETED")
		_:
			assert(false)
	return &"%s<%s#%d>" % [
		prefix,
		get_name(),
		get_instance_id(),
	]
