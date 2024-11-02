class_name Permutation

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

func get_inputs() -> Array:
	var s := []
	for i: int in range(_set_digits.size() - 1, -1, -1):
		var j := _set_digits[i]
		var v: Variant = _set[j]
		match _set_inputs[j]:
			_INPUT_RAW:
				s.push_back(v)
			_INPUT_COMPLETED:
				s.push_back(Task.completed(v))
			_INPUT_CANCELED:
				s.push_back(Task.canceled())
			_INPUT_DEFER:
				s.push_back(Task.defer())
	return s

func get_output(index: int) -> Variant:
	return _set[_set_digits[_set_digits.size() - index - 1]]

func get_outputs() -> Array:
	var s := []
	for i: int in range(_set_digits.size() - 1, -1, -1):
		s.push_back(_set[_set_digits[i]])
	return s

func push(value: Variant) -> void:
	_set.push_back(value)
	_set_inputs.push_back(_INPUT_RAW)

func push_completed(value: Variant = null) -> void:
	_set.push_back(value)
	_set_inputs.push_back(_INPUT_COMPLETED)

func push_canceled() -> void:
	_set.push_back(null)
	_set_inputs.push_back(_INPUT_CANCELED)

func push_defer() -> void:
	_set.push_back(null)
	_set_inputs.push_back(_INPUT_DEFER)

func next() -> bool:
	if _first:
		_first = false
		return true
	for i: int in _set_digits.size():
		_set_digits[i] += 1
		if _set_digits[i] < _set.size():
			return true
		_set_digits[i] = 0
	return false

#-------------------------------------------------------------------------------

enum {
	_INPUT_RAW,
	_INPUT_COMPLETED,
	_INPUT_CANCELED,
	_INPUT_DEFER,
}

var _first := true
var _set := []
var _set_inputs: Array[int] = []
var _set_digits: Array[int] = []

func _init(length: int) -> void:
	_set_digits.resize(length)
