#-------------------------------------------------------------------------------
#
#
#	Copyright 2022-2024 Ydi (@ydipeepo.bsky.social)
#
#
#	Permission is hereby granted, free of charge, to any person obtaining
#	a copy of this software and associated documentation files (the "Software"),
#	to deal in the Software without restriction, including without limitation
#	the rights to use, copy, modify, merge, publish, distribute, sublicense,
#	and/or sell copies of the Software, and to permit persons to whom
#	the Software is furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#	OTHER DEALINGS IN THE SOFTWARE.
#
#
#-------------------------------------------------------------------------------

## 将来決まる値を抽象化するためのクラスです。
class_name Task extends Awaitable

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

## 条件一致を省略するためのプレースホルダです。[br]
## [br]
## この定数は [method from_conditional_signal]、[from_conditional_signal_name] で使用します。
static var SKIP := Object.new()

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## 完了した [Task] を作成します。
static func completed(result: Variant = null) -> Task:
	return XDUT_CompletedTask.new(result)

## キャンセルされた [Task] を作成します。
static func canceled() -> Task:
	return XDUT_CanceledTask.new()

## 完了もキャンセルされることもない [Task] を作成します。[br]
## [br]
## この [Task] は [param cancel] 引数を指定するか、[method wait] に [Cancel] を渡さない限りキャンセルできません。
static func never(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_NeverTask.new(cancel)

## [Task] に変換します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。
static func from(
	from_init: Variant,
	cancel: Cancel = null) -> Task:

	if from_init is Array:
		match from_init.size():
			3:
				if from_init[0] is Object and (from_init[1] is String or from_init[1] is StringName):
					if from_init[2] is int:
						return from_signal_name(
							from_init[0],
							from_init[1],
							from_init[2],
							cancel)
					if from_init[2] is Array:
						return from_conditional_signal_name(
							from_init[0],
							from_init[1],
							from_init[2],
							cancel)
			2:
				if from_init[0] is Object and (from_init[1] is String or from_init[1] is StringName):
					if from_init[0].has_method(from_init[1]):
						return from_method_name(
							from_init[0],
							from_init[1],
							cancel)
					if from_init[0].has_signal(from_init[1]):
						return from_signal_name(
							from_init[0],
							from_init[1],
							0,
							cancel)
				if from_init[0] is Signal:
					if from_init[1] is int:
						return from_signal(
							from_init[0],
							from_init[1],
							cancel)
					if from_init[1] is Array:
						return from_conditional_signal(
							from_init[0],
							from_init[1],
							cancel)
			1:
				if from_init[0] is Awaitable:
					return from_init[0]
				if from_init[0] is Object:
					if from_init[0].has_method(&"wait"):
						return from_method_name(
							from_init[0],
							&"wait",
							cancel)
					if from_init[0].has_signal(&"completed"):
						return from_signal_name(
							from_init[0],
							&"completed",
							0,
							cancel)
				if from_init[0] is Callable:
					return from_method(
						from_init[0],
						cancel)
				if from_init[0] is Signal:
					return from_signal(
						from_init[0],
						0,
						cancel)
	if from_init is Awaitable:
		return from_init
	if from_init is Object:
		if from_init.has_method(&"wait"):
			return from_method_name(
				from_init,
				&"wait",
				cancel)
		if from_init.has_signal(&"completed"):
			return from_signal_name(
				from_init,
				&"completed",
				0,
				cancel)
	if from_init is Callable:
		return from_method(
			from_init,
			cancel)
	if from_init is Signal:
		return from_signal(
			from_init,
			0,
			cancel)

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return completed(from_init)

## メソッドを [Task] に変換します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。[br]
## - [code]() -> Variant[/code][br]
## - [code](cancel: Cancel) -> Variant[/code][br]
## メソッドの戻り値がこの [Task] の結果になります。
static func from_method(
	method: Callable,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return canceled()
	if not method.get_argument_count() in XDUT_FromMethodTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return canceled()

	return XDUT_FromMethodTask.new(
		method,
		cancel)

## オブジェクトに定義されているメソッドを [Task] 変換します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。[br]
## - [code]() -> Variant[/code][br]
## - [code](cancel: Cancel) -> Variant[/code][br]
## メソッドの戻り値がこの [Task] の結果になります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
static func from_method_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return canceled()
	if not object.get_method_argument_count(method_name) in XDUT_FromMethodNameTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
		return canceled()

	return XDUT_FromMethodNameTask.new(
		object,
		method_name,
		cancel)

## コールバックを [Task] に変換します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。[br]
## - [code](resolve: Callable) -> void[/code][br]
## - [code](resolve: Callable, reject: Callable) -> void[/code][br]
## - [code](resolve: Callable, reject: Callable, cancel: Cancel) -> void[/code][br]
## [code]resolve[/code] に渡した引数がこの [Task] の結果となります。
static func from_callback(
	method: Callable,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return canceled()
	if not method.get_argument_count() in XDUT_FromCallbackTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return canceled()

	return XDUT_FromCallbackTask.new(
		method,
		cancel)

## オブジェクトに定義されているコールバックを [Task] に変換します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。[br]
## - [code](set_: Callable) -> void[/code][br]
## - [code](set_: Callable, cancel: Callable) -> void[/code][br]
## [code]resolve[/code] に渡した引数がこの [Task] の結果となります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
static func from_callback_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return canceled()
	if not object.get_method_argument_count(method_name) in XDUT_FromCallbackNameTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
		return canceled()

	return XDUT_FromCallbackNameTask.new(
		object,
		method_name,
		cancel)

## シグナルを [Task] に変換します。[br]
## [br]
## [param signal_argc] にはシグナルの引数の数を指定します。[br]
## シグナル引数を配列に格納したものがこの [Task] の結果となります。
static func from_signal(
	signal_: Signal,
	signal_argc := 0,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(signal_.get_object()) or signal_.is_null():
		push_error("Invalid object associated with signal.")
		return canceled()
	if signal_argc < 0 and XDUT_FromSignalTask.MAX_SIGNAL_ARGC < signal_argc:
		push_error("Invalid signal argument count: ", signal_argc)
		return canceled()

	return XDUT_FromSignalTask.new(
		signal_,
		signal_argc,
		cancel)

## オブジェクトに定義されているシグナルを [Task] に変換します。[br]
## [br]
## [param signal_argc] にはシグナルの引数の数を指定します。[br]
## シグナル引数を配列に格納したものがこの [Task] の結果となります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
static func from_signal_name(
	object: Object,
	signal_name: StringName,
	signal_argc := 0,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_signal(signal_name):
		push_error("Invalid signal name: ", signal_name)
		return canceled()
	if signal_argc < 0 and XDUT_FromSignalNameTask.MAX_SIGNAL_ARGC < signal_argc:
		push_error("Invalid signal argument count: ", signal_argc)
		return canceled()

	return XDUT_FromSignalNameTask.new(
		object,
		signal_name,
		signal_argc,
		cancel)

## シグナルが条件に一致する引数で発火したとき完了する [Task] を作成します。[br]
## [br]
## 条件に一致したシグナル引数を配列に格納したものがこの [Task] の結果となります。
static func from_conditional_signal(
	signal_: Signal,
	signal_args := [],
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(signal_.get_object()) or signal_.is_null():
		push_error("Invalid object associated with signal.")
		return canceled()
	if XDUT_FromConditionalSignalTask.MAX_SIGNAL_ARGC < signal_args.size():
		push_error("Invalid signal argument count: ", signal_args.size())
		return canceled()

	return XDUT_FromConditionalSignalTask.new(
		signal_,
		signal_args,
		cancel)

## オブジェクトに定義されているシグナルが条件に一致する引数で発火したとき完了する [Task] を作成します。[br]
## [br]
## 条件に一致したシグナル引数を配列に格納したものがこの [Task] の結果となります。[br]
## このタスクは [param object] に対する強い参照を保持します。
static func from_conditional_signal_name(
	object: Object,
	signal_name: StringName,
	signal_args := [],
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_signal(signal_name):
		push_error("Invalid signal name: ", signal_name)
		return canceled()
	if XDUT_FromConditionalSignalNameTask.MAX_SIGNAL_ARGC < signal_args.size():
		push_error("Invalid signal argument count: ", signal_args.size())
		return canceled()

	return XDUT_FromConditionalSignalNameTask.new(
		object,
		signal_name,
		signal_args,
		cancel)

## アイドル状態となるまで待機する [Task] を作成します。[br]
## [br]
## ここでのアイドル状態とは、プロセス、物理プロセスを抜けた直後、すなわち [method Node.call_deferred] で遅延した処理が開始されるタイミングを指します。
static func defer(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_DeferTask.new()

## 次のルートプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルートプロセスフレームとは、エンジンに設定されている [signal MainLoop.process_frame] が発火するタイミングを指します。[br]
## [method defer_process] より優先しますが、フレーム末尾 ([method Node._process] の末尾) まで待機することはできません。[br]
## [method Node.get_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_process_frame(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_DeferProcessFrameTask.new(cancel)

## 次のルート物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルート物理フレームとは、エンジンに設定されている [signal MainLoop.physics_frame] が発火するタイミングを指します。[br]
## [method defer_physics] より優先しますが、フレーム末尾 ([method Node._physics_process] の末尾) まで待機することはできません。[br]
## [method Node.get_physics_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_physics_frame(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_DeferPhysicsFrameTask.new(cancel)

## 次のプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのプロセスフレームとは、カノニカルの [method Node._process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_process(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_DeferProcessTask.new(cancel)

## 次の物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでの物理フレームとは、カノニカルの [method Node._physics_process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_physics(cancel: Cancel = null) -> Task:
	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_DeferPhysicsTask.new(cancel)

## タイムアウトするまで待機する [Task] を作成します。[br]
## [br]
## [param timeout] がこの [Task] の結果となります。
static func delay(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if timeout < XDUT_DelayTask.MIN_TIMEOUT:
		push_warning("Invalid timeout.")
		return completed()
	if timeout == XDUT_DelayTask.MIN_TIMEOUT:
		return completed()

	return XDUT_DelayTask.new(
		timeout,
		ignore_pause,
		ignore_time_scale,
		cancel)

## タイムアウト (ミリ秒で指定) するまで待機する [Task] を作成します。[br]
## [br]
## [param timeout] を [code]1,000[/code] で割った値がこの [Task] の結果となります。
static func delay_msec(
	timeout: int,
	cancel: Cancel = null) -> Task:

	return delay(
		timeout / 1_000.0,
		false,
		false,
		cancel)

## タイムアウト (マイクロ秒で指定) するまで待機する [Task] を作成します。[br]
## [br]
## [param timeout] を [code]1,000,000[/code] で割った値がこの [Task] の結果となります。
static func delay_usec(
	timeout: int,
	cancel: Cancel = null) -> Task:

	return delay(
		timeout / 1_000 / 1_000.0,
		false,
		false,
		cancel)

## 全ての入力が完了するまで待機する [Task] を作成します。[br]
## [br]
## [param from_inits] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。[Awaitable] はアンラップされます。
static func all(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if from_inits.is_empty():
		return completed([])

	return XDUT_AllTask.new(
		from_inits,
		cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_inits] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。リテラルは [Task] にラップされます。
static func all_settled(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if from_inits.is_empty():
		return completed([])

	return XDUT_AllSettledTask.new(
		from_inits,
		cancel)

## 入力の内どれかひとつが完了するまで待機する [Task] を作成します。[br]
## [br]
## [param from_inits] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了したものが結果となります。[Awaitable] はアンラップされます。
static func any(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if from_inits.is_empty():
		return canceled()

	return XDUT_AnyTask.new(
		from_inits,
		cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_inits] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了もしくはキャンセルされたものが結果となります。リテラルは [Task] にラップされます。
static func race(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if from_inits.is_empty():
		push_warning("Invalid inputs.")
		return never(cancel)

	return XDUT_RaceTask.new(
		from_inits,
		cancel)

## アイドル状態となるまで待機します。
static func wait_defer(cancel: Cancel = null) -> Variant:
	return await defer(cancel).wait(cancel)

## 次のルートプロセスフレームまで待機します。
static func wait_defer_process_frame(cancel: Cancel = null) -> Variant:
	return await defer_process_frame(cancel).wait(cancel)

## 次のルート物理フレームまで待機します。
static func wait_defer_physics_frame(cancel: Cancel = null) -> Variant:
	return await defer_physics_frame(cancel).wait(cancel)

## 次のプロセスフレームまで待機します。
static func wait_defer_process(cancel: Cancel = null) -> Variant:
	return await defer_process(cancel).wait(cancel)

## 次の物理フレームまで待機します。
static func wait_defer_physics(cancel: Cancel = null) -> Variant:
	return await defer_physics(cancel).wait(cancel)

## タイムアウトするまで待機します。
static func wait_delay(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false,
	cancel: Cancel = null) -> Variant:

	return await delay(
		timeout,
		ignore_pause,
		ignore_time_scale,
		cancel).wait(cancel)

## タイムアウト (ミリ秒で指定) するまで待機します。
static func wait_delay_msec(
	timeout: int,
	cancel: Cancel = null) -> Variant:

	return await delay_msec(
		timeout,
		cancel).wait(cancel)

## タイムアウト (マイクロ秒で指定) するまで待機します。
static func wait_delay_usec(
	timeout: int,
	cancel: Cancel = null) -> Variant:

	return await delay_usec(
		timeout,
		cancel).wait(cancel)

## 全ての入力が完了するまで待機します。
static func wait_all(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await all(
		from_inits,
		cancel).wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機します。
static func wait_all_settled(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await all_settled(
		from_inits,
		cancel).wait(cancel)

## 入力の内どれかひとつが完了するまで待機します。
static func wait_any(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await any(
		from_inits,
		cancel).wait(cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機します。
static func wait_race(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await race(
		from_inits,
		cancel).wait(cancel)

## 結果を受け取り継続させる [Task] を作成します。
static func create_then(
	prev: Awaitable,
	then_init: Variant,
	cancel: Cancel = null) -> Task:

	if then_init is Array:
		match then_init.size():
			2:
				if then_init[0] is Object and (then_init[1] is String or then_init[1] is StringName):
					if then_init[0].has_method(then_init[1]):
						return create_then_method_name(
							prev,
							then_init[0],
							then_init[1],
							cancel)
			1:
				if then_init[0] is Object:
					if then_init[0].has_method(&"wait"):
						return create_then_method_name(
							prev,
							then_init[0],
							&"wait",
							cancel)
				if then_init[0] is Callable:
					return create_then_method(
						prev,
						then_init[0],
						cancel)
	if then_init is Awaitable:
		return XDUT_ThenTask.new(
			prev,
			then_init,
			cancel)
	if then_init is Object:
		if then_init.has_method(&"wait"):
			return create_then_method_name(
				prev,
				then_init,
				&"wait",
				cancel)
	if then_init is Callable:
		return create_then_method(
			prev,
			then_init,
			cancel)

	if is_instance_valid(cancel) and cancel.is_requested:
		return canceled()

	return XDUT_ThenTask.new(
		prev,
		then_init,
		cancel)

## 結果をメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method(
	prev: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	if not is_instance_valid(prev) or prev.is_canceled or is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return canceled()
	if not method.get_argument_count() in XDUT_ThenMethodTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return canceled()

	return XDUT_ThenMethodTask.new(
		prev,
		method,
		cancel)

## 結果をオブジェクトに定義されているメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method_name(
	prev: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	if not is_instance_valid(prev) or prev.is_canceled or is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return canceled()
	if not object.get_method_argument_count(method_name) in XDUT_ThenMethodNameTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
		return canceled()

	return XDUT_ThenMethodNameTask.new(
		prev,
		object,
		method_name,
		cancel)

## 結果をコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback(
	prev: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	if not is_instance_valid(prev) or prev.is_canceled or is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not method.is_valid():
		push_error("Invalid object associated with method.")
		return canceled()
	if not method.get_argument_count() in XDUT_ThenCallbackTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", method.get_argument_count())
		return canceled()

	return XDUT_ThenCallbackTask.new(
		prev,
		method,
		cancel)

## 結果をオブジェクトに定義されているコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback_name(
	prev: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	if not is_instance_valid(prev) or prev.is_canceled or is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if not is_instance_valid(object):
		push_error("Invalid object.")
		return canceled()
	if not object.has_method(method_name):
		push_error("Invalid method name: ", method_name)
		return canceled()
	if not object.get_method_argument_count(method_name) in XDUT_ThenCallbackNameTask.ACCEPTIBLE_METHOD_ARGC:
		push_error("Invalid method argument count: ", object.get_method_argument_count(method_name))
		return canceled()

	return XDUT_ThenCallbackNameTask.new(
		prev,
		object,
		method_name,
		cancel)

## 結果をアンラップする [Task] を作成します。
static func create_unwrap(
	prev: Awaitable,
	depth := 1,
	cancel: Cancel = null) -> Task:

	if not is_instance_valid(prev) or is_instance_valid(cancel) and cancel.is_requested:
		return canceled()
	if depth < 0:
		push_error("Invalid depth.")
		return canceled()
	if depth == 0:
		return prev

	return XDUT_UnwrapTask.new(
		prev,
		depth,
		cancel)

## この [Task] の完了後、結果を受け取り継続させる [Task] を作成します。[br]
## [br]
## [param then_init] はルールに沿って正規化されます。詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/task-クラス#正規化規則]正規化規則[/url]をご覧ください。
func then(
	then_init: Variant,
	cancel: Cancel = null) -> Task:

	return create_then(self, then_init, cancel)

## この [Task] の完了後、結果をメソッドで受け取り継続させる [Task] を作成します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。[br]
## - [code]() -> Variant[/code][br]
## - [code](cancel: Cancel) -> Variant[/code][br]
## メソッドの戻り値がこの [Task] の結果になります。
func then_method(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return create_then_method(
		self,
		method,
		cancel)

## この [Task] の完了後、結果をオブジェクトに定義されているメソッドで受け取り継続させる [Task] を作成します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。[br]
## - [code]() -> Variant[/code][br]
## - [code](cancel: Cancel) -> Variant[/code][br]
## メソッドの戻り値がこの [Task] の結果になります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
func then_method_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return create_then_method_name(
		self,
		object,
		method_name,
		cancel)

## この [Task] の完了後、結果をコールバックで受け取り継続させる [Task] を作成します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。[br]
## - [code](result: Variant, resolve: Callable) -> void[/code][br]
## - [code](result: Variant, resolve: Callable, reject: Callable) -> void[/code][br]
## - [code](result: Variant, resolve: Callable, reject: Callable, cancel: Cancel) -> void[/code][br]
## [code]resolve[/code] に渡した引数がこの [Task] の結果となります。
func then_callback(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return create_then_callback(
		self,
		method,
		cancel)

## この [Task] の完了後、結果をオブジェクトに定義されているコールバックで受け取り継続させる [Task] を作成します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。[br]
## - [code](result: Variant, resolve: Callable) -> void[/code][br]
## - [code](result: Variant, resolve: Callable, reject: Callable) -> void[/code][br]
## - [code](result: Variant, resolve: Callable, reject: Callable, cancel: Cancel) -> void[/code][br]
## [code]resolve[/code] に渡した引数がこの [Task] の結果となります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
func then_callback_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return create_then_callback_name(
		self,
		object,
		method_name,
		cancel)

## この [Task] の完了後、結果をアンラップする [Task] を作成します。
func unwrap(
	depth := 1,
	cancel: Cancel = null) -> Task:

	return create_unwrap(
		self,
		depth,
		cancel)

#-------------------------------------------------------------------------------

func _to_string() -> String:
	var str: String
	match get_state():
		STATE_PENDING:
			str = "(pending)"
		STATE_PENDING_WITH_WAITERS:
			str = "(pending_with_waiters)"
		STATE_CANCELED:
			str = "(canceled)"
		STATE_COMPLETED:
			str = "(completed)"
		_:
			assert(false)
	return str + "<Task#%d>" % get_instance_id()
