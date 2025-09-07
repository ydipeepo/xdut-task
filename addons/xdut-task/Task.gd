## 将来決まる値を抽象化するためのクラスです。
@abstract
class_name Task extends Awaitable

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

## 条件一致を省略するためのプレースホルダです。[br]
## [br]
## この定数は、[br]
## - [method from_conditional_signal]、[br]
## - [from_conditional_signal_name] で使用します。
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
## この [Task] は [param cancel] 引数を指定するか、[br]
## [method wait] に [Cancel] を渡さない限りキャンセルできません。
static func never(cancel: Cancel = null) -> Task:
	return XDUT_NeverTask.create(cancel, false)

## [Task] に変換します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。
static func from_v(
	from_init: Variant,
	cancel: Cancel = null) -> Task:

	return XDUT_FromTask.create(
		from_init,
		cancel,
		false)

## [Task] に変換します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。
static func from(...from_init: Array) -> Task:
	var cancel: Cancel = null
	if not from_init.is_empty() and from_init.back() is Cancel:
		cancel = from_init.pop_back()
	return from_v(from_init, cancel)

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

	return XDUT_FromCallbackTask.create(
		method,
		cancel,
		false)

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

	return XDUT_FromCallbackNameTask.create(
		object,
		method_name,
		cancel,
		false)

## メソッドを [Task] に変換します。[br]
## [br]
## メソッドは以下のシグネチャに一致している必要があります。[br]
## - [code]() -> Variant[/code][br]
## - [code](cancel: Cancel) -> Variant[/code][br]
## メソッドの戻り値がこの [Task] の結果になります。
static func from_method(
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_FromMethodTask.create(
		method,
		cancel,
		false)

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
## シグナル引数を配列に格納したものがこの [Task] の結果となります。[br]
## この [Task] は [param object] に対する強い参照を保持します。
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
## 条件に一致したシグナル引数を配列に格納したものがこの [Task] の結果となります。[br]
## このタスクは [param object] に対する強い参照を保持します。
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
	return XDUT_DeferTask.create(
		cancel,
		false)

## 次のルートプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルートプロセスフレームとは、エンジンに設定されている [signal MainLoop.process_frame] が発火するタイミングを指します。[br]
## [method defer_process] より優先しますが、[br]
## フレーム末尾 ([method Node._process] の末尾) まで待機することはできません。[br]
## [method Node.get_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_process_frame(cancel: Cancel = null) -> Task:
	return XDUT_DeferProcessFrameTask.create(
		cancel,
		false)

## 次のルート物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのルート物理フレームとは、エンジンに設定されている [signal MainLoop.physics_frame] が発火するタイミングを指します。[br]
## [method defer_physics] より優先しますが、[br]
## フレーム末尾 ([method Node._physics_process] の末尾) まで待機することはできません。[br]
## [method Node.get_physics_process_delta_time] の戻り値がこの [Task] の結果となります。
static func defer_physics_frame(cancel: Cancel = null) -> Task:
	return XDUT_DeferPhysicsFrameTask.create(
		cancel,
		false)

## 次のプロセスフレームまで待機する [Task] を作成します。[br]
## [br]
## ここでのプロセスフレームとは、カノニカルの [method Node._process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_process(cancel: Cancel = null) -> Task:
	return XDUT_DeferProcessTask.create(
		cancel,
		false)

## 次の物理フレームまで待機する [Task] を作成します。[br]
## [br]
## ここでの物理フレームとは、カノニカルの [method Node._physics_process] が呼ばれるタイミングを指します。[br]
## [code]delta[/code] がこの [Task] の結果となります。
static func defer_physics(cancel: Cancel = null) -> Task:
	return XDUT_DeferPhysicsTask.create(
		cancel,
		false)

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
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。[Awaitable] はアンラップされます。
static func all_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_AllTask.create(
		from_inits,
		cancel,
		false)

## 全ての入力が完了するまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。[Awaitable] はアンラップされます。
static func all(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return all_v(from_inits, cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返す [Task] を作成します。
static func all_count_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_AllCountTask.create(
		from_inits,
		cancel,
		false)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返す [Task] を作成します。
static func all_count(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return all_count_v(from_inits, cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。リテラルは [Task] にラップされます。
static func all_settled_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_AllSettledTask.create(
		from_inits,
		cancel,
		false)

## 全ての入力が完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] を配列に格納したものが結果となります。リテラルは [Task] にラップされます。
static func all_settled(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return all_settled_v(from_inits, cancel)

## 入力の内どれかひとつが完了するまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了したものが結果となります。[Awaitable] はアンラップされます。
static func any_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_AnyTask.create(
		from_inits,
		cancel,
		false)

## 入力の内どれかひとつが完了するまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了したものが結果となります。[Awaitable] はアンラップされます。
static func any(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return any_v(from_inits, cancel)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返す [Task] を作成します。
static func any_index_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_AnyIndexTask.create(
		from_inits,
		cancel,
		false)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返す [Task] を作成します。
static func any_index(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return any_index_v(from_inits, cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了もしくはキャンセルされたものが結果となります。リテラルは [Task] にラップされます。
static func race_v(
	from_inits: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_RaceTask.create(
		from_inits,
		cancel,
		false)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機する [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。[br]
## [param from_inits] の内最初に完了もしくはキャンセルされたものが結果となります。リテラルは [Task] にラップされます。
static func race(...from_inits: Array) -> Task:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return race_v(from_inits, cancel)

## リソースを読み込むタスクを作成します。[br]
## [br]
## [param resource_path] はリソースパスを指定します。[br]
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

## アイドル状態となるまで待機します。
static func wait_defer(cancel: Cancel = null) -> Variant:
	return await defer(cancel) \
		.wait(cancel)

## 次のルートプロセスフレームまで待機します。
static func wait_defer_process_frame(cancel: Cancel = null) -> Variant:
	return await defer_process_frame(cancel) \
		.wait(cancel)

## 次のルート物理フレームまで待機します。
static func wait_defer_physics_frame(cancel: Cancel = null) -> Variant:
	return await defer_physics_frame(cancel) \
		.wait(cancel)

## 次のプロセスフレームまで待機します。
static func wait_defer_process(cancel: Cancel = null) -> Variant:
	return await defer_process(cancel) \
		.wait(cancel)

## 次の物理フレームまで待機します。
static func wait_defer_physics(cancel: Cancel = null) -> Variant:
	return await defer_physics(cancel) \
		.wait(cancel)

## タイムアウトするまで待機します。
static func wait_delay(
	timeout: float,
	ignore_pause := false,
	ignore_time_scale := false,
	cancel: Cancel = null) -> Variant:

	return await delay(timeout, ignore_pause, ignore_time_scale, cancel) \
		.wait(cancel)

## タイムアウト (ミリ秒で指定) するまで待機します。
static func wait_delay_msec(
	timeout: int,
	cancel: Cancel = null) -> Variant:

	return await delay_msec(timeout, cancel) \
		.wait(cancel)

## タイムアウト (マイクロ秒で指定) するまで待機します。
static func wait_delay_usec(
	timeout: int,
	cancel: Cancel = null) -> Variant:

	return await delay_usec(timeout, cancel) \
		.wait(cancel)

## 全ての入力が完了するまで待機します。
static func wait_all_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await all_v(from_inits, cancel) \
		.wait(cancel)

## 全ての入力が完了するまで待機します。
static func wait_all(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await all_v(from_inits, cancel) \
		.wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返します。
static func wait_all_count_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await all_count_v(from_inits, cancel) \
		.wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機し完了した入力数を返します。
static func wait_all_count(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await all_count_v(from_inits, cancel) \
		.wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機します。
static func wait_all_settled_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await all_settled_v(from_inits, cancel) \
		.wait(cancel)

## 全ての入力が完了もしくはキャンセルされるまで待機します。
static func wait_all_settled(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await all_settled_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了するまで待機します。
static func wait_any_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await any_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了するまで待機します。
static func wait_any(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await any_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返します。
static func wait_any_index_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await any_index_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了するまで待機し完了した入力のインデックスを返します。
static func wait_any_index(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await any_index_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機します。
static func wait_race_v(
	from_inits: Array,
	cancel: Cancel = null) -> Variant:

	return await race_v(from_inits, cancel) \
		.wait(cancel)

## 入力の内どれかひとつが完了もしくはキャンセルされるまで待機します。
static func wait_race(...from_inits: Array) -> Variant:
	var cancel: Cancel = null
	if not from_inits.is_empty() and from_inits.back() is Cancel:
		cancel = from_inits.pop_back()
	return await race_v(from_inits, cancel) \
		.wait(cancel)

## 結果を受け取り継続させる [Task] を作成します。
static func create_then_v(
	source_awaitable: Awaitable,
	then_init: Variant,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenTask.create(
		source_awaitable,
		then_init,
		cancel,
		false)

## 結果を受け取り継続させる [Task] を作成します。
static func create_then(
	source_awaitable: Awaitable,
	...then_init: Array) -> Task:

	var cancel: Cancel = null
	if not then_init.is_empty() and then_init.back() is Cancel:
		cancel = then_init.pop_back()
	return create_then_v(source_awaitable, then_init, cancel)

## 結果をコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenCallbackTask.create(
		source_awaitable,
		method,
		cancel,
		false)

## 結果をオブジェクトに定義されているコールバックで受け取り継続させる [Task] を作成します。
static func create_then_callback_name(
	prev: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenCallbackNameTask.create(
		prev,
		object,
		method_name,
		cancel,
		false)

## 結果をメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method(
	source_awaitable: Awaitable,
	method: Callable,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenMethodTask.create(
		source_awaitable,
		method,
		cancel,
		false)

## 結果をオブジェクトに定義されているメソッドで受け取り継続させる [Task] を作成します。
static func create_then_method_name(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenMethodNameTask.create(
		source_awaitable,
		object,
		method_name,
		cancel,
		false)

## メソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
static func create_then_bound_method(
	source_awaitable: Awaitable,
	method: Callable,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenBoundMethodTask.create(
		source_awaitable,
		method,
		method_args,
		cancel,
		false)

## オブジェクトに定義されているメソッドに引数を束縛し結果を受け取り継続させる [Task] を作成します。
static func create_then_bound_method_name(
	source_awaitable: Awaitable,
	object: Object,
	method_name: StringName,
	method_args: Array,
	cancel: Cancel = null) -> Task:

	return XDUT_ThenBoundMethodNameTask.create(
		source_awaitable,
		object,
		method_name,
		method_args,
		cancel,
		false)

## 結果をアンラップする [Task] を作成します。
static func create_unwrap(
	source_awaitable: Awaitable,
	depth := 1,
	cancel: Cancel = null) -> Task:

	return XDUT_UnwrapTask.create(
		source_awaitable,
		depth,
		cancel,
		false)

## この [Task] の完了後、結果を受け取り継続させる [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。
func then_v(
	then_init: Variant,
	cancel: Cancel = null) -> Task:

	return create_then_v(self, then_init, cancel)

## この [Task] の完了後、結果を受け取り継続させる [Task] を作成します。[br]
## [br]
## [param from_init] はルールに沿って正規化されます。[br]
## 詳しくは[url=https://github.com/ydipeepo/xdut-task/wiki/%E6%AD%A3%E8%A6%8F%E5%8C%96%E8%A6%8F%E5%89%87]正規化規則[/url]をご覧ください。
func then(...then_init: Array) -> Task:
	var cancel: Cancel = null
	if not then_init.is_empty() and then_init.back() is Cancel:
		cancel = then_init.pop_back()
	return then_v(then_init, cancel)

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
func unwrap(
	depth := 1,
	cancel: Cancel = null) -> Task:

	return create_unwrap(
		self,
		depth,
		cancel)
