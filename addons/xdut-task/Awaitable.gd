## 将来決まる値を抽象化するための共通のインターフェイスクラスです。
@abstract
class_name Awaitable

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

enum {
	## 結果を待機しています。
	STATE_PENDING,

	## 結果を待機しており、[method wait] によりブロックされている呼び出しが一つ以上あります。
	STATE_PENDING_WITH_WAITERS,

	## 完了しました。[br]
	## [br]
	## これ以上状態は変化しません。
	STATE_COMPLETED,

	## キャンセルされました。[br]
	## [br]
	## これ以上状態は変化しません。
	STATE_CANCELED,
}

#-------------------------------------------------------------------------------
#	PROPERTIES
#-------------------------------------------------------------------------------

## この [Awaitable] が完了している場合は [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## このプロパティの返す値は、[br]
## [code]get_state() == STATE_COMPLETED[/code] と等価です。
var is_completed: bool:
	get:
		return get_state() == STATE_COMPLETED

## この [Awaitable] がキャンセルされている場合は [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## このプロパティの返す値は、[br]
## [code]get_state() == STATE_CANCELED[/code] と等価です。
var is_canceled: bool:
	get:
		return get_state() == STATE_CANCELED

## この [Awaitable] が完了もキャンセルもされておらず結果を待機している場合は [code]true[/code]、
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## このプロパティの返す値は、[br]
## [code]get_state() in [STATE_PENDING, STATE_PENDING_WITH_WAITERS] と等価です。
var is_pending: bool:
	get:
		var state := get_state()
		return \
			state == STATE_PENDING or \
			state == STATE_PENDING_WITH_WAITERS

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func get_canonical() -> Node:
	if not is_instance_valid(_canonical):
		_canonical = Engine \
			.get_main_loop() \
			.root \
			.get_node("/root/XDUT_TaskCanonical")
	if not is_instance_valid(_canonical):
		_canonical = null
	return _canonical

## この [Awaitable] の状態を取得します。
@abstract
func get_state() -> int

## この [Awaitable] の結果が決まるまで待機します。[br]
## [br]
## キャンセルされている場合は [code]null[/code] を返します。
@abstract
func wait(cancel: Cancel = null) -> Variant

#-------------------------------------------------------------------------------

static var _canonical: Node

func _to_string() -> String:
	var prefix: String
	match get_state():
		STATE_PENDING:
			prefix = get_canonical() \
				.translate(&"TASK_STATE_PENDING")
		STATE_PENDING_WITH_WAITERS:
			prefix = get_canonical() \
				.translate(&"TASK_STATE_PENDING_WITH_WAITERS")
		STATE_CANCELED:
			prefix = get_canonical() \
				.translate(&"TASK_STATE_CANCELED")
		STATE_COMPLETED:
			prefix = get_canonical() \
				.translate(&"TASK_STATE_COMPLETED")
		_:
			assert(false)
	return &"%s<Awaitable#%d>" % [prefix, get_instance_id()]
