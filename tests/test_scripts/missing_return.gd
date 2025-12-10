extends Node

## Test script with missing return statements
## Note: Using untyped returns to avoid Godot parse errors
## ScriptGraph will still detect missing return paths

func get_value_incomplete(condition: bool):
	# ⚠️ ScriptGraph should warn: missing return in else branch
	if condition:
		return 42


func calculate_result(a: int, b: int):
	# ⚠️ ScriptGraph should warn: missing return when a == b
	if a > b:
		return a
	elif b > a:
		return b


func proper_function(value: int) -> int:
	# ✅ All paths have returns - no warning expected
	if value > 0:
		return value
	else:
		return 0


func no_return_function() -> void:
	# ✅ void functions are fine - no warning expected
	print("This function doesn't need a return")


func conditional_return_example(flag: bool):
	# ⚠️ Another example of missing return
	if flag:
		print("Processing...")
		return true
	# Missing return when flag is false
