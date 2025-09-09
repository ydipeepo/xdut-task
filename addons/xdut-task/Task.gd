## 将来決まる値を抽象化するためのクラスです。
@abstract
class_name Task extends Awaitable

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

## 条件一致を省略するためのプレースホルダです。[br]
## [br]
## 💡 この定数は、[method from_conditional_signal]、[method from_conditional_signal_name] で使用します。
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

## 完了もキャンセルされることもない [Task] を作成します。
static func never(cancel: Cancel = null) -> Task:
	return XDUT_NeverTask.create(cancel, false)

## [Task] に変換します。[br]
## [br]
## [param init] は以下のルールに沿って正規化されます。
## [codeblock]
## # 以下の変換に対応しています。
## # 下に行くほど優先度が下がります。
##
## # メソッドが定義されていれば、from_bound_method_name に委譲されます。
## Task.from_v([Object, String|StringName, Array])
##
## # シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from_v([Object, String|StringName, int])
##
## # シグナルが定義されていれば、from_conditional_signal_name に委譲されます。
## Task.from_v([Object, String|StringName, Array])
##
## # メソッドが定義されていれば、from_method_name に委譲されます。
## Task.from_v([Object, String|StringName])
##
## # シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from_v([Object, String|StringName])
##
## # from_bound_method_name に委譲されます。
## Task.from_v([Callable, Array])
##
## # from_signal に委譲されます。
## Task.from_v([Signal, int])
##
## # from_conditional_signal に委譲されます。
## Task.from_v([Signal, Array])
##
## # 指定した Awaitable をラップして返します。
## Task.from_v([Awaitable])
##
## # wait メソッドが定義されていれば、from_method_name に委譲されます。
## Task.from_v([Object])
##
## # completed シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from_v([Object])
##
## # from_method に委譲されます。
## Task.from_v([Callable])
##
## # from_signal に委譲されます。
## Task.from_v([Signal])
##
## # 指定した Awaitable をラップして返します。
## Task.from_v(Awaitable)
##
## # wait メソッドが定義されていれば、from_method_name に委譲されます。
## Task.from_v(Object)
##
## # completed シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from_v(Object)
##
## # from_method に委譲されます。
## Task.from_v(Callable)
##
## # from_signal に委譲されます。
## Task.from_v(Signal)
##
## # 他全て completed に委譲されます。
## Task.from(123)
## [/codeblock]
static func from_v(init: Variant, cancel: Cancel = null) -> Task:
	return XDUT_FromTask.create(init, cancel, false)

## [Task] に変換します。[br]
## [br]
## [param init] は以下のルールに沿って正規化されます。
## [codeblock]
## # 以下の変換に対応しています。
## # 下に行くほど優先度が下がります。
##
## # メソッドが定義されていれば、from_bound_method_name に委譲されます。
## Task.from(Object, String|StringName, Array)
##
## # シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from(Object, String|StringName, int)
##
## # シグナルが定義されていれば、from_conditional_signal_name に委譲されます。
## Task.from(Object, String|StringName, Array)
##
## # メソッドが定義されていれば、from_method_name に委譲されます。
## Task.from(Object, String|StringName)
##
## # シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from(Object, String|StringName)
##
## # from_bound_method_name に委譲されます。
## Task.from(Callable, Array)
##
## # from_signal に委譲されます。
## Task.from(Signal, int)
##
## # from_conditional_signal に委譲されます。
## Task.from(Signal, Array)
##
## # 指定した Awaitable をラップして返します。
## Task.from(Awaitable)
##
## # wait メソッドが定義されていれば、from_method_name に委譲されます。
## Task.from(Object)
##
## # completed シグナルが定義されていれば、from_signal_name に委譲されます。
## Task.from(Object)
##
## # from_method に委譲されます。
## Task.from(Callable)
##
## # from_signal に委譲されます。
## Task.from(Signal)
##
## # 他全て completed に委譲されます。
## Task.from(123)
## [/codeblock]
## [br]
## 💡 [param init] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func from(...init: Array) -> Task:
	return XDUT_FromTask.create_with_extract_cancel(init, false)

## コールバックを [Task] に変換します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。
## [codeblock]
## func f(resolve: Callable) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##
## func g(resolve: Callable, reject: Callable) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##     # reject を呼び出すことでキャンセルさせます。
##     reject.call()
##
## func h(resolve: Callable, reject: Callable, cancel: Cancel) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##     # reject を呼び出すことでキャンセルさせます。
##     reject.call()
##
## Task.from_callback(f)
## Task.from_callback(g)
## Task.from_callback(h)
## [/codeblock]
static func from_callback(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_FromCallbackTask.create(
		method,
		cancel,
		false)

## オブジェクトに定義されているコールバックを [Task] に変換します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。
## [codeblock]
## class MyClass:
##
##     func f(resolve: Callable) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##
##     func g(resolve: Callable, reject: Callable) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##         # reject を呼び出すことでキャンセルさせます。
##         reject.call()
##
##     func h(resolve: Callable, reject: Callable, cancel: Cancel) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##         # reject を呼び出すことでキャンセルさせます。
##         reject.call()
##
## var mc := MyClass.new()
## Task.from_callback_name(mc, &"f")
## Task.from_callback_name(mc, &"g")
## Task.from_callback_name(mc, &"h")
## [/codeblock]
## [br]
## ❗ この [Task] は [param object] に対する強い参照を保持します。
static func from_callback_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_FromCallbackNameTask.create(
		object,
		method_name,
		cancel,
		false)

## メソッドを [Task] に変換します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。
## [codeblock]
## func f() -> Variant:
##     return 123 # タスクの結果となります。(int に限りません)
##
## func g(cancel: Cancel) -> Variant:
##     return 123 # タスクの結果となります。(int に限りません)
##
## Task.from_method(f)
## Task.from_method(g)
## [/codeblock]
static func from_method(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_FromMethodTask.create(
		method,
		cancel,
		false)

## オブジェクトに定義されているメソッドを [Task] 変換します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。
## [codeblock]
## class MyClass:
##
##     func f() -> Variant:
##         return 123 # タスクの結果となります。(int に限りません)
##
##     func g(cancel: Cancel) -> Variant:
##         return 123 # タスクの結果となります。(int に限りません)
##
## var mc := MyClass.new()
## Task.from_method_name(mc, &"f")
## Task.from_method_name(mc, &"g")
## [/codeblock]
## [br]
## ❗ この [Task] は [param object] に対する強い参照を保持します。
static func from_method_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_FromMethodNameTask.create(
		object,
		method_name,
		cancel,
		false)

## メソッドに引数を束縛し [Task] に変換します。
static func from_bound_method(
	method: Callable,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_FromBoundMethodTask.create(
		method,
		method_args,
		cancel,
		false)

## オブジェクトに定義されているメソッドに引数を束縛し [Task] に変換します。
static func from_bound_method_name(
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_FromBoundMethodNameTask.create(
		object,
		method_name,
		method_args,
		cancel,
		false)

## シグナルを [Task] に変換します。[br]
## [br]
## [param signal_argc] にはシグナルの引数の数を指定します。[br]
## シグナル引数を配列に格納したものがこの [Task] の結果となります。
## [codeblock]
## signal my_signal
## signal my_signal_with_args(a: int, b: bool, c: String)
##
## var t1 := Task.from_signal(my_signal)
## var t2 := Task.from_signal(my_signal_with_args, 3)
## my_signal.emit()
## my_signal_with_args.emit(123, true, "abc")
## print(await t1.wait()) # []
## print(await t2.wait()) # [123, true, "abc"]
## [/codeblock]
static func from_signal(
	signal_: Signal,
	signal_argc := 0,
	cancel: Cancel = null) -> Task:

	return XDUT_FromSignalTask.create(
		signal_,
		signal_argc,
		cancel,
		false)

## オブジェクトに定義されているシグナルを [Task] に変換します。[br]
## [br]
## [param signal_argc] にはシグナルの引数の数を指定します。[br]
## シグナル引数を配列に格納したものがこの [Task] の結果となります。
## [codeblock]
## class MyClass:
##
##     signal my_signal
##     signal my_signal_with_args(a: int, b: bool, c: String)
##
## var mc := MyClass.new()
## var t1 := Task.from_signal_name(mc, &"my_signal")
## var t2 := Task.from_signal_name(mc, &"my_signal_with_args", 3)
## mc.my_signal.emit()
## mc.my_signal_with_args.emit(123, true, "abc")
## print(await t1.wait()) # []
## print(await t2.wait()) # [123, true, "abc"]
## [/codeblock]
## [br]
## ❗ この [Task] は [param object] に対する強い参照を保持します。
static func from_signal_name(
	object: Object,
	signal_name: StringName,
	signal_argc := 0,
	cancel: Cancel = null) -> Task:

	return XDUT_FromSignalNameTask.create(
		object,
		signal_name,
		signal_argc,
		cancel,
		false)

## シグナルが条件に一致する引数で発火したとき完了する [Task] を作成します。[br]
## [br]
## 条件に一致したシグナル引数を配列に格納したものがこの [Task] の結果となります。
## [codeblock]
## signal my_signal_with_args(a: int, b: bool, c: String)
##
## var t := Task.from_conditional_signal(my_signal_with_args, [Task.SKIP, true, "abc"])
## my_signal_with_args.emit(123, false, "def")
## print(t.is_pending)   # true
## my_signal_with_args.emit(456, true, "abc")
## print(t.is_pending)   # false
## print(await t.wait()) # [456, true, "abc"]
## [/codeblock]
static func from_conditional_signal(
	signal_: Signal,
	signal_args := [],
	cancel: Cancel = null) -> Task:

	return XDUT_FromConditionalSignalTask.create_conditional(
		signal_,
		signal_args,
		cancel,
		false)

## オブジェクトに定義されているシグナルが条件に一致する引数で発火したとき完了する [Task] を作成します。[br]
## [br]
## 条件に一致したシグナル引数を配列に格納したものがこの [Task] の結果となります。
## [codeblock]
## class MyClass:
##
##     signal my_signal_with_args(a: int, b: bool, c: String)
##
## var mc := MyClass.new()
## var t := Task.from_conditional_signal_name(mc, &"my_signal_with_args", [Task.SKIP, true, "abc"])
## my_signal_with_args.emit(123, false, "def")
## print(t.is_pending)   # true
## my_signal_with_args.emit(456, true, "abc")
## print(t.is_pending)   # false
## print(await t.wait()) # [456, true, "abc"]
## [/codeblock]
## [br]
## ❗ このタスクは [param object] に対する強い参照を保持します。
static func from_conditional_signal_name(
	object: Object,
	signal_name: StringName,
	signal_args := [],
	cancel: Cancel = null) -> Task:

	return XDUT_FromConditionalSignalNameTask.create_conditional(
		object,
		signal_name,
		signal_args,
		cancel,
		false)

## アイドル状態となるまで待機する [Task] を作成します。[br]
## [br]
## ここでのアイドル状態とは、プロセス、物理プロセスを抜けた直後、[br]
## すなわち [method Node.call_deferred] で遅延した処理が開始されるタイミングを指します。
static func defer(cancel: Cancel = null) -> Task:
	return XDUT_DeferTask.create(cancel, false)

## 次のルートプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルートプロセスフレームとは、エンジンに設定されている [signal MainLoop.process_frame] が発火するタイミングを指します。[br]
## [method defer_process] より優先しますが、[br]
## フレーム末尾 ([method Node._process] の末尾) まで待機することはできません。[br]
## [method Node.get_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_process_frame(cancel: Cancel = null) -> Task:
	return XDUT_DeferProcessFrameTask.create(cancel, false)

## 次のルート物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルート物理フレームとは、エンジンに設定されている [signal MainLoop.physics_frame] が発火するタイミングを指します。[br]
## [method defer_physics] より優先しますが、[br]
## フレーム末尾 ([method Node._physics_process] の末尾) まで待機することはできません。[br]
## [method Node.get_physics_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_physics_frame(cancel: Cancel = null) -> Task:
	return XDUT_DeferPhysicsFrameTask.create(cancel, false)

## 次のプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのプロセスフレームとは、カノニカルの [method Node._process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_process(cancel: Cancel = null) -> Task:
	return XDUT_DeferProcessTask.create(cancel, false)

## 次の物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでの物理フレームとは、カノニカルの [method Node._physics_process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_physics(cancel: Cancel = null) -> Task:
	return XDUT_DeferPhysicsTask.create(cancel, false)

## タイムアウトするまで待機する [Task] を作成します。[br]
## [br]
## [param timeout] がこの [Task] の結果となります。
static func delay(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false,
	cancel: Cancel = null) -> Task:

	return XDUT_DelayTask.create(
		timeout,
		ignore_pause,
		ignore_time_scale,
		cancel,
		false)

## タイムアウト (ミリ秒で指定) するまで待機する [Task] を作成します。[br]
## [br]
## 💡 [param timeout] を [code]1,000[/code] で割った値がこの [Task] の結果となります。
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
## 💡 [param timeout] を [code]1,000,000[/code] で割った値がこの [Task] の結果となります。
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
## [param init_array] を配列に格納したものが結果となります。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func all_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_AllTask.create(init_array, cancel, false)

## 全ての入力が完了するまで待機する [Task] を作成します。[br]
## [br]
## [param init_array_with_cancel] を配列に格納したものが結果となります。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func all(...init_array_with_cancel: Array) -> Task:
	return XDUT_AllTask.create_with_extract_cancel(init_array_with_cancel, false)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返す [Task] を作成します。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func all_count_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_AllCountTask.create(init_array, cancel, false)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返す [Task] を作成します。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func all_count(...init_array_with_cancel: Array) -> Task:
	return XDUT_AllCountTask.create_with_extract_cancel(init_array_with_cancel, false)

## 全ての入力が完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param init_array] を配列に格納したものが結果となります。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func all_settled_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_AllSettledTask.create(init_array, cancel, false)

## 全ての入力が完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param init_array_with_cancel] を配列に格納したものが結果となります。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func all_settled(...init_array_with_cancel: Array) -> Task:
	return XDUT_AllSettledTask.create_with_extract_cancel(init_array_with_cancel, false)

## 入力の内どれかひとつが完了するまで待機する [Task] を作成します。[br]
## [br]
## [param init_array] の内最初に完了したものが結果となります。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func any_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_AnyTask.create(init_array, cancel, false)

## 入力の内どれかひとつが完了するまで待機する [Task] を作成します。[br]
## [br]
## [param init_array_with_cancel] を配列に格納したものが結果となります。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func any(...init_array_with_cancel: Array) -> Task:
	return XDUT_AnyTask.create_with_extract_cancel(init_array_with_cancel, false)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返す [Task] を作成します。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func any_index_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_AnyIndexTask.create(init_array, cancel, false)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返す [Task] を作成します。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func any_index(...init_array_with_cancel: Array) -> Task:
	return XDUT_AnyIndexTask.create_with_extract_cancel(init_array_with_cancel, false)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param init_array] の内最初に完了もしくはキャンセルされたものが結果となります。[br]
## [br]
## 💡 [param init_array] の各成分は [method from_v] と同一のルールに沿って正規化されます。
static func race_v(init_array: Array, cancel: Cancel = null) -> Task:
	return XDUT_RaceTask.create(init_array, cancel, false)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param init_array] の内最初に完了もしくはキャンセルされたものが結果となります。[br]
## [br]
## 💡 [param init_array_with_cancel] の各成分は [method from_v] と同一のルールに沿って正規化されます。[br]
## 💡 [param init_array_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
static func race(...init_array_with_cancel: Array) -> Task:
	return XDUT_RaceTask.create_with_extract_cancel(init_array_with_cancel, false)

## リソースを読み込むタスクを作成します。[br]
## [br]
## [param resource_path] はリソースパスを、[br]
## [param resource_type] はリソースのタイプヒントを指定します。
static func load(
	resource_path: String,
	resource_type := &"",
	cache_mode := ResourceLoader.CACHE_MODE_IGNORE,
	cancel: Cancel = null) -> Task:

	return XDUT_LoadTask.create(
		resource_path,
		resource_type,
		cache_mode,
		cancel,
		false)

## アイドル状態となるまで待機します。[br]
## [br]
## 💡 このメソッドは [method defer] タスクを待機します。
static func wait_defer(cancel: Cancel = null) -> Variant:
	return await defer(cancel).wait(cancel)

## 次のルートプロセスフレームまで待機します。[br]
## [br]
## 💡 このメソッドは [method defer_process_frame] タスクを待機します。
static func wait_defer_process_frame(cancel: Cancel = null) -> Variant:
	return await defer_process_frame(cancel).wait(cancel)

## 次のルート物理フレームまで待機します。[br]
## [br]
## 💡 このメソッドは [method defer_physics_frame] タスクを待機します。
static func wait_defer_physics_frame(cancel: Cancel = null) -> Variant:
	return await defer_physics_frame(cancel).wait(cancel)

## 次のプロセスフレームまで待機します。[br]
## [br]
## 💡 このメソッドは [method defer_process] タスクを待機します。
static func wait_defer_process(cancel: Cancel = null) -> Variant:
	return await defer_process(cancel).wait(cancel)

## 次の物理フレームまで待機します。[br]
## [br]
## 💡 このメソッドは [method defer_physics] タスクを待機します。
static func wait_defer_physics(cancel: Cancel = null) -> Variant:
	return await defer_physics(cancel).wait(cancel)

## タイムアウトするまで待機します。[br]
## [br]
## 💡 このメソッドは [method delay] タスクを待機します。
static func wait_delay(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false,
	cancel: Cancel = null) -> Variant:

	return await delay(timeout, ignore_pause, ignore_time_scale, cancel) \
		.wait(cancel)

## タイムアウト (ミリ秒で指定) するまで待機します。[br]
## [br]
## 💡 このメソッドは [method delay_msec] タスクを待機します。
static func wait_delay_msec(timeout: int, cancel: Cancel = null) -> Variant:
	return await delay_msec(timeout, cancel).wait(cancel)

## タイムアウト (マイクロ秒で指定) するまで待機します。[br]
## [br]
## 💡 このメソッドは [method delay_usec] タスクを待機します。
static func wait_delay_usec(timeout: int, cancel: Cancel = null) -> Variant:
	return await delay_usec(timeout, cancel).wait(cancel)

## 全ての入力が完了するまで待機します。[br]
## [br]
## 💡 このメソッドは [method all_v] タスクを待機します。
static func wait_all_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await all_v(init_array, cancel).wait(cancel)

## 全ての入力が完了するまで待機します。[br]
## [br]
## 💡 このメソッドは [method all] タスクを待機します。
static func wait_all(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await all_v(init_array_with_cancel, cancel).wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返します。[br]
## [br]
## 💡 このメソッドは [method all_count_v] タスクを待機します。
static func wait_all_count_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await all_count_v(init_array, cancel).wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返します。[br]
## [br]
## 💡 このメソッドは [method all_count] タスクを待機します。
static func wait_all_count(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await all_count_v(init_array_with_cancel, cancel).wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機します。[br]
## [br]
## 💡 このメソッドは [method all_settled_v] タスクを待機します。
static func wait_all_settled_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await all_settled_v(init_array, cancel).wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機します。[br]
## [br]
## 💡 このメソッドは [method all_settled] タスクを待機します。
static func wait_all_settled(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await all_settled_v(init_array_with_cancel, cancel).wait(cancel)

## 入力の内どれかひとつが完了するまで待機します。[br]
## [br]
## 💡 このメソッドは [method any_v] タスクを待機します。
static func wait_any_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await any_v(init_array, cancel).wait(cancel)

## 入力の内どれかひとつが完了するまで待機します。[br]
## [br]
## 💡 このメソッドは [method any] タスクを待機します。
static func wait_any(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await any_v(init_array_with_cancel, cancel).wait(cancel)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返します。[br]
## [br]
## 💡 このメソッドは [method any_index_v] タスクを待機します。
static func wait_any_index_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await any_index_v(init_array, cancel).wait(cancel)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返します。[br]
## [br]
## 💡 このメソッドは [method any_index] タスクを待機します。
static func wait_any_index(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await any_index_v(init_array_with_cancel, cancel).wait(cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機します。[br]
## [br]
## 💡 このメソッドは [method race_v] タスクを待機します。
static func wait_race_v(init_array: Array, cancel: Cancel = null) -> Variant:
	return await race_v(init_array, cancel).wait(cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機します。[br]
## [br]
## 💡 このメソッドは [method race] タスクを待機します。
static func wait_race(...init_array_with_cancel: Array) -> Variant:
	var cancel: Cancel = null
	if not init_array_with_cancel.is_empty() and init_array_with_cancel.back() is Cancel:
		cancel = init_array_with_cancel.pop_back()
	return await race_v(init_array_with_cancel, cancel).wait(cancel)

## 結果を受け取り継続させる [Task] を作成します。
static func create_then_v(
	source: Awaitable,
	init: Variant,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenTask.create(
		source,
		init,
		cancel,
		false)

## 結果を受け取り継続させる [Task] を作成します。
static func create_then(
	source: Awaitable,
	init_with_cancel: Array) -> Task:

	return XDUT_ThenTask.create_with_extract_cancel(
		source,
		init_with_cancel,
		false)

## 結果をコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback(
	source: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenCallbackTask.create(
		source,
		method,
		cancel,
		false)

## 結果をオブジェクトに定義されているコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback_name(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenCallbackNameTask.create(
		source,
		object,
		method_name,
		cancel,
		false)

## 結果をメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method(
	source: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenMethodTask.create(
		source,
		method,
		cancel,
		false)

## 結果をオブジェクトに定義されているメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method_name(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenMethodNameTask.create(
		source,
		object,
		method_name,
		cancel,
		false)

## メソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
static func create_then_bound_method(
	source: Awaitable,
	method: Callable,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenBoundMethodTask.create(
		source,
		method,
		method_args,
		cancel,
		false)

## オブジェクトに定義されているメソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
static func create_then_bound_method_name(
	source: Awaitable,
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenBoundMethodNameTask.create(
		source,
		object,
		method_name,
		method_args,
		cancel,
		false)

## 結果をアンラップする [Task] を作成します。
static func create_unwrap(
	source: Awaitable,
	depth := 1,
	cancel: Cancel = null) -> Task:

	return XDUT_UnwrapTask.create(
		source,
		depth,
		cancel,
		false)

## この [Task] の完了後、結果を受け取り継続させる [Task] を作成します。[br]
## [br]
## [param init] は以下のルールに沿って正規化されます。
## [codeblock]
## # 以下の変換に対応しています。
## # 下に行くほど優先度が下がります。
##
## # メソッドが定義されていれば、from_bound_method_name に委譲し継続させます。
## Task.completed().then_v([Object, String|StringName, Array])
##
## # メソッドが定義されていれば、from_method_name に委譲し継続させます。
## Task.completed().then_v([Object, String|StringName])
##
## # from_bound_method_name に委譲し継続させます。
## Task.completed().then_v([Callable, Array])
##
## # 指定した Awaitable をラップし継続させます。
## Task.completed().then_v([Awaitable])
##
## # wait メソッドが定義されていれば、from_method_name に委譲し継続させます。
## Task.completed().then_v([Object])
##
## # from_method に委譲し継続させます。
## Task.completed().then_v([Callable])
##
## # 指定した Awaitable をラップし継続させます。
## Task.completed().then_v(Awaitable)
##
## # wait メソッドが定義されていれば、from_method_name に委譲し継続させます。
## Task.completed().then_v(Object)
##
## # from_method に委譲し継続させます。
## Task.completed().then_v(Callable)
## [/codeblock]
func then_v(init: Variant, cancel: Cancel = null) -> Task:
	return create_then_v(self, init, cancel)

## この [Task] の完了後、結果を受け取り継続させる [Task] を作成します。[br]
## [br]
## [param init_with_cancel] は以下のルールに沿って正規化されます。
## [codeblock]
## # 以下の変換に対応しています。
## # 下に行くほど優先度が下がります。
##
## # メソッドが定義されていれば、from_bound_method_name に委譲し継続させます。
## Task.completed().then(Object, String|StringName, Array)
##
## # メソッドが定義されていれば、from_method_name に委譲し継続させます。
## Task.completed().then(Object, String|StringName)
##
## # from_bound_method_name に委譲し継続させます。
## Task.completed().then(Callable, Array)
##
## # 指定した Awaitable をラップし継続させます。
## Task.completed().then(Awaitable)
##
## # wait メソッドが定義されていれば、from_method_name に委譲し継続させます。
## Task.completed().then(Object)
##
## # from_method に委譲し継続させます。
## Task.completed().then(Callable)
## [/codeblock]
## [br]
## 💡 [param init_with_cancel] には末尾に [Cancel] を与えることができますが、正規化よりも [Cancel] 抽出が優先します。
func then(...init_with_cancel: Array) -> Task:
	return create_then(self, init_with_cancel)

## この [Task] の完了後、結果をコールバックで受け取り継続させる [Task] を作成します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。
## [codeblock]
## func f(result: Variant, resolve: Callable) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##
## func g(result: Variant, resolve: Callable, reject: Callable) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##     # reject を呼び出すことでキャンセルさせます。
##     reject.call()
##
## func h(result: Variant, resolve: Callable, reject: Callable, cancel: Cancel) -> void:
##     # resolve を呼び出すことで完了させます。
##     # 引数を渡しタスクの結果にすることもできます。
##     resolve.call() # resolve.call(123)
##     # reject を呼び出すことでキャンセルさせます。
##     reject.call()
##
## Task.completed().then_callback(f)
## Task.completed().then_callback(g)
## Task.completed().then_callback(h)
## [/codeblock]
func then_callback(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return create_then_callback(
		self,
		method,
		cancel)

## この [Task] の完了後、結果をオブジェクトに定義されているコールバックで受け取り継続させる [Task] を作成します。[br]
## [br]
## コールバックは以下のシグネチャに一致している必要があります。
## [codeblock]
## class MyClass:
##
##     func f(result: Variant, resolve: Callable) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##
##     func g(result: Variant, resolve: Callable, reject: Callable) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##         # reject を呼び出すことでキャンセルさせます。
##         reject.call()
##
##     func h(result: Variant, resolve: Callable, reject: Callable, cancel: Cancel) -> void:
##         # resolve を呼び出すことで完了させます。
##         # 引数を渡しタスクの結果にすることもできます。
##         resolve.call() # resolve.call(123)
##         # reject を呼び出すことでキャンセルさせます。
##         reject.call()
##
## var mc := MyClass.new()
## Task.completed().then_callback_name(mc, &"f")
## Task.completed().then_callback_name(mc, &"g")
## Task.completed().then_callback_name(mc, &"h")
## [/codeblock]
## [br]
## ❗ この [Task] は [param object] に対する強い参照を保持します。
func then_callback_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return create_then_callback_name(
		self,
		object,
		method_name,
		cancel)

## この [Task] の完了後、結果をメソッドで受け取り継続させる [Task] を作成します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。
## [codeblock]
## func f() -> Variant:
##     return 123 # タスクの結果となります。(int に限りません)
##
## func g(cancel: Cancel) -> Variant:
##     return 123 # タスクの結果となります。(int に限りません)
##
## Task.completed().then_method(f)
## Task.completed().then_method(g)
## [/codeblock]
func then_method(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return create_then_method(
		self,
		method,
		cancel)

## この [Task] の完了後、結果をオブジェクトに定義されているメソッドで受け取り継続させる [Task] を作成します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。
## [codeblock]
## class MyClass:
##
##     func f() -> Variant:
##         return 123 # タスクの結果となります。(int に限りません)
##
##     func g(cancel: Cancel) -> Variant:
##         return 123 # タスクの結果となります。(int に限りません)
##
## var mc := MyClass.new()
## Task.completed().then_method_name(mc, &"f")
## Task.completed().then_method_name(mc, &"g")
## [/codeblock]
## [br]
## ❗ この [Task] は [param object] に対する強い参照を保持します。
func then_method_name(
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return create_then_method_name(
		self,
		object,
		method_name,
		cancel)

## この [Task] の完了後、メソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
func then_bound_method(
	method: Callable,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return create_then_bound_method(
		self,
		method,
		method_args,
		cancel)

## この [Task] の完了後、オブジェクトに定義されているメソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
func then_bound_method_name(
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return create_then_bound_method_name(
		self,
		object,
		method_name,
		method_args,
		cancel)

## この [Task] の完了後、結果をアンラップする [Task] を作成します。
func unwrap(depth := 1, cancel: Cancel = null) -> Task:
	return create_unwrap(self, depth, cancel)
