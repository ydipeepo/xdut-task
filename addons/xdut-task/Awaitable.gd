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

## 将来決まる値を抽象化するための共通のインターフェイスクラスです。
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
## このプロパティの返す値は [code]get_state() == STATE_COMPLETED[/code] と等価です。
var is_completed: bool:
	get:
		return get_state() == STATE_COMPLETED

## この [Awaitable] がキャンセルされている場合は [code]true[/code]、[br]
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## このプロパティの返す値は [code]get_state() == STATE_CANCELED[/code] と等価です。
var is_canceled: bool:
	get:
		return get_state() == STATE_CANCELED

## この [Awaitable] が完了もキャンセルもされておらず結果を待機している場合は [code]true[/code]、
## それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## このプロパティの返す値は [code]get_state() in [STATE_PENDING, STATE_PENDING_WITH_WAITERS] と等価です。
var is_pending: bool:
	get:
		var state := get_state()
		return \
			state == STATE_PENDING or \
			state == STATE_PENDING_WITH_WAITERS

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## この [Awaitable] の状態を取得します。
func get_state() -> int:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return STATE_PENDING

## この [Awaitable] の結果が決まるまで待機します。[br]
## [br]
## キャンセルされている場合は [code]null[/code] を返します。
func wait(cancel: Cancel = null) -> Variant:
	#
	# 継承先で実装する必要があります。
	#

	assert(false)
	return await null
