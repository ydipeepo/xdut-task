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

## 外部から [Awaitable] をキャンセルするためのクラスです。
class_name Cancel

#-------------------------------------------------------------------------------
#	SIGNALS
#-------------------------------------------------------------------------------

## キャンセルが要求されると発火します。[br]
## [br]
## [member is_requested] が [code]true[/code] の場合、このシグナルは発火しません。[br]
## 先に [member is_requested] を確認するようにしてください。
signal requested

#-------------------------------------------------------------------------------
#	PROPERTIES
#-------------------------------------------------------------------------------

## キャンセルが要求されていれば [code]true[/code]、それ以外の場合は [code]false[/code] を返します。[br]
## [br]
## 一度キャンセルが要求されると取り下げることはできず、それ以降必ず [code]true[/code] を返します。
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

## キャンセルが要求されていれば [code]true[/code]、それ以外の場合は [code]false[/code] を返します。
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
