## 外部から [Awaitable] をキャンセルするためのクラスです。
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

## キャンセルが要求されていれば [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。
func get_requested() -> bool:
	#
	# 継承先で実装する必要があります。
	#
	
	assert(false)
	return false

## キャンセルを要求します。
func request() -> void:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
