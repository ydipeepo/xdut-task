## 外部から [Awaitable] をキャンセルするためのクラスです。
@abstract
class_name Cancel

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

## キャンセルが要求されると発火します。[br]
## [br]
## [member is_requested] が [code]true[/code] の場合、[br]
## このシグナルは発火しません。[br]
## 先に [member is_requested] を確認するようにしてください。
signal requested

#-------------------------------------------------------------------------------
#	PROPERTIES
#-------------------------------------------------------------------------------

## キャンセルが要求されていれば [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## 一度キャンセルが要求されると取り下げることはできず、[br]
## それ以降必ず [code]true[/code] を返します。
var is_requested: bool:
	get = get_requested

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func internal_task_get_canonical() -> Node:
	if not is_instance_valid(_canonical):
		_canonical = Engine \
			.get_main_loop() \
			.root \
			.get_node("/root/XDUT_TaskCanonical")
	assert(is_instance_valid(_canonical), "XDUT Task is not activated.")
	return _canonical

## キャンセルされていない [Cancel] を作成します。
static func create() -> Cancel:
	return XDUT_CancelBase.new(&"Cancel")

## 既にキャンセルが要求された状態の [Cancel] を作成します。
static func canceled() -> Cancel:
	return XDUT_CanceledCancel.new()

## フレームの末尾でキャンセルを要求する [Cancel] を作成します。
static func deferred() -> Cancel:
	return XDUT_DeferredCancel.new()

## タイムアウトするとキャンセルを要求する [Cancel] を作成します。
static func timeout(
	timeout_: float,
	ignore_pause := false,
	ignore_time_scale := false) -> Cancel:

	return XDUT_TimeoutCancel.new(
		timeout_,
		ignore_pause,
		ignore_time_scale)

## シグナルが発火すると要求される [Cancel] を作成します。[br]
## [br]
## 引数を受け取らないシグナルのみ使用できます。[br]
## シグナルオブジェクトが無効になってもキャンセルは要求されません。
static func from_signal(signal_: Signal) -> Cancel:
	return XDUT_FromSignalCancel.new(signal_)

## オブジェクトに定義されているシグナルが発火すると要求される [Cancel] を作成します。[br]
## [br]
## 引数を受け取らないシグナルのみ使用できます。[br]
## シグナルオブジェクトが無効になってもキャンセルは要求されません。
static func from_signal_name(
	object: Object,
	signal_name: StringName) -> Cancel:

	return XDUT_FromSignalNameCancel.new(
		object,
		signal_name)

## キャンセルが要求されていれば [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。
@abstract
func get_requested() -> bool

## キャンセルを要求します。
@abstract
func request() -> void

#-------------------------------------------------------------------------------

static var _canonical: Node
