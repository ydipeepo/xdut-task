class_name Task_ThenMethod extends Test

class Callsite:

	func noop() -> void:
		pass

	func noop_return() -> int:
		return 123

	func fork() -> void:
		await _test.wait_defer()

	func fork_return() -> int:
		await _test.wait_defer()
		return 123

	var _test: Test

	func _init(test: Test) -> void:
		_test = test

func 継続_完了したタスクから() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait()
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait(Cancel.canceled())
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了したタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())
	await task2.wait(Cancel.deferred())
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait()
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_完了するタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait(Cancel.canceled())
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_completed())

func 継続_完了するタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[1].call_deferred()
	await task2.wait(Cancel.deferred())
	is_true(marks[0])
	is_true(task1.is_completed())
	is_true(task2.is_completed())

func 継続_キャンセルされたタスクから() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait()
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait(Cancel.canceled())
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされたタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var task1 := Task.canceled()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())
	await task2.wait(Cancel.deferred())
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait()
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_即時() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait(Cancel.canceled())
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_canceled())
	await wait_defer()
	is_true(task1.is_canceled())

func 継続_キャンセルされるタスクから_キャンセルあり_遅延() -> void:
	var marks: Array[bool] = [false]
	var opers := Task.with_operators()
	if not is_not_empty(opers):
		return
	var task1: Task = opers[0]
	var task2 := task1.then_method(func() -> void:
		marks[0] = true)
	if not is_not_null(task2):
		return
	is_false(marks[0])
	is_true(task1.is_pending())
	is_true(task2.is_pending())
	opers[2].call_deferred()
	await task2.wait(Cancel.deferred())
	is_false(marks[0])
	is_true(task1.is_canceled())
	is_true(task2.is_canceled())

func 状態遷移_空() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func 状態遷移_空_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_空_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(Callable())
	if not is_not_null(task2):
		return
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func 状態遷移_ラムダ() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		pass)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> void:
		await wait_defer())
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_ラムダ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_待機_リテラル() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_ラムダ_待機_リテラル_キャンセルあり_即時() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_ラムダ_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(func() -> int:
		await wait_defer()
		return 123)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

#
# NOTE:
#
# class MyRefCounted:
#     func _notification(what: int) -> void:
#         if what == NOTIFICATION_PREDELETE:
#             print("predelete")
#
# signal _defer
#
# func test() -> void:
#     var ref := MyRefCounted.new()
#     print(ref.get_reference_count())
#     if "scope":
#         var closure := func() -> RefCounted:
#             print(ref.get_reference_count())
#             return ref
#         print(ref.get_reference_count())
#         closure.call()
#         print(ref.get_reference_count())
#     print(ref.get_reference_count()) # (*)
#     _defer.emit.call_deferred(); await _defer
#     print(ref.get_reference_count()) # (*)
#
# func _ready() -> void:
#     await test()
#     print("exited call_test")
#
# > 1
# > 2
# > 3
# > 2
# > 2 # (*) not 1
# > 2 # (*) not 1
# > predelete
# > exited test
#
# The lifetime of objects bound to closures appears to be implemented on
# Godot 4.5.0 to synchronize with the stack frame that
# created the closure, rather than with the closure body.
# We don't know if this is a bug or an intentional implementation,
# but as you can see from the code above, it is correctly deleted.
#
# To follow this behavior, we assert that the reference count after leaving
# the closure's scope is 1 higher than the value expected from the context.
#

func 状態遷移_ラムダ_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		await task2.wait()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_ラムダ_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		await task2.wait(Cancel.canceled())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_ラムダ_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_completed())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
		await task2.wait(Cancel.deferred())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_フォーク_ラムダ_待機_参照() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())

		#
		# NOTE:
		#
		# Because it has entered a spin path waiting for the CustomTask._release signal,
		# the order of the CustomTask.release_complete call and stack release is reversed.
		#
		#  1. CustomTask.wait call
		#  2. Wait for CustomTask._release inside CustomTask.wait
		#  3. method completion inside _FromMethodTask._fork
		#  4. CustomTask.release_complete call
		#  5. CustomTask._release.emit call
		#  6. CustomTask._release release inside CustomTask.wait
		#  7. CustomTask.wait return
		#
		# At this point, the stack from _FromMethodTask._fork still remains,
		# and it is necessary to release the stack to obtain an accurate reference count.
		# Here, the process is yielded once to allow the _FromMethodTask._fork trailer
		# to process and revert the reference increment from the stack.
		#
		#   * Normally, this is not necessary! This is solely for testing purposes.
		#

		await task2.wait(); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_フォーク_ラムダ_待機_参照_キャンセルあり_即時() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		await task2.wait(Cancel.canceled()); await wait_defer()
		are_equal(2, ref.get_reference_count())
		is_true(task2.is_canceled())
	are_equal(2, ref.get_reference_count())

func 状態遷移_フォーク_ラムダ_待機_参照_キャンセルあり_遅延() -> void:
	var ref := RefCounted.new()
	if "scope":
		var task1: Task
		var task2: Task
		if "scope":
			task1 = Task.completed()
			if not is_not_null(task1):
				return
			task2 = task1.then_method(func() -> RefCounted:
				are_equal(3, ref.get_reference_count())
				await wait_defer()
				are_equal(3, ref.get_reference_count())
				return ref)
			if not is_not_null(task2):
				return
			are_equal(3, ref.get_reference_count())
			is_true(task2.is_pending())
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_pending())
		await task2.wait(Cancel.deferred()); await wait_defer()
		are_equal(3, ref.get_reference_count())
		is_true(task2.is_completed())
	are_equal(2, ref.get_reference_count())

func 状態遷移_メソッド() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func 状態遷移_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.noop_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_待機_リテラル() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func 状態遷移_フォーク_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func 状態遷移_フォーク_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var callsite := Callsite.new(self)
	var task1 := Task.completed()
	if not is_not_null(task1):
		return
	var task2 := task1.then_method(callsite.fork_return)
	if not is_not_null(task2):
		return
	is_true(task2.is_pending())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_メソッド() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process(1)
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process(1)
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process(1)
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())

func スコープ_メソッド_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait())
	is_true(task2.is_completed())

func スコープ_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.canceled()))
	is_true(task2.is_completed())

func スコープ_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.noop_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_completed())
	is_true(task2.is_completed())
	are_equal(123, await task2.wait(Cancel.deferred()))
	is_true(task2.is_completed())

func スコープ_フォーク_メソッド_待機_リテラル() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process()
	is_true(task2.is_canceled())
	is_null(await task2.wait())
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_待機_リテラル_キャンセルあり_即時() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process()
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.canceled()))
	is_true(task2.is_canceled())

func スコープ_フォーク_メソッド_待機_リテラル_キャンセルあり_遅延() -> void:
	var task1: Task
	var task2: Task
	if "scope":
		var callsite := Callsite.new(self)
		task1 = Task.completed()
		if not is_not_null(task1):
			return
		task2 = task1.then_method(callsite.fork_return)
		if not is_not_null(task2):
			return
		is_true(task2.is_pending())
	is_true(task2.is_pending())
	await wait_defer_process()
	is_true(task2.is_canceled())
	is_null(await task2.wait(Cancel.deferred()))
	is_true(task2.is_canceled())
