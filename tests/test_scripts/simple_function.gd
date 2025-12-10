extends Node

## Simple test script with basic function

func _ready():
	print("Hello from ScriptGraph!")
	var result = add_numbers(5, 10)
	print("Result: ", result)


func add_numbers(a: int, b: int) -> int:
	return a + b
