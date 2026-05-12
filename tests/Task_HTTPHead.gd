class_name Task_HTTPHead extends Test

func 状態遷移() -> void:
	var task := Task.http_head("https://http.codes/200", [], 1.0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var response: Variant = await task.wait()
	if not is_true(task.is_completed()):
		return
	if not are_equal(200, response.status_code):
		return
	is_true("content-type: text/plain;charset=UTF-8" in response.headers)

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.http_head("https://http.codes/200", [], 1.0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())
