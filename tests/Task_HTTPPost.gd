class_name Task_HTTPPost extends Test

func 状態遷移() -> void:
	var task := Task.http_post("https://http.codes/200", [], "hello", 1.0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	var response: Variant = await task.wait()
	if not is_true(task.is_completed()):
		return
	if not are_equal(200, response.status_code):
		return
	if not is_true("content-type: text/plain;charset=UTF-8" in response.headers):
		return
	are_equal("200 OK", response.body.get_string_from_utf8())

func 状態遷移_キャンセルあり_即時() -> void:
	var task := Task.http_post("https://http.codes/200", [], "hello", 1.0)
	if not is_not_null(task):
		return
	is_true(task.is_pending())
	is_null(await task.wait(Cancel.canceled()))
	is_true(task.is_canceled())
