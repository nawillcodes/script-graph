extends Node

## Unit Test Script for ScriptGraph
## This script demonstrates various control flow patterns

var test_value: int = 0
var items: Array = ["a", "b", "c"]


func _ready() -> void:
	run_all_tests()


func run_all_tests() -> void:
	print("Running tests...")
	test_simple_condition()
	test_nested_conditions()
	test_loop_patterns()
	test_early_returns("test_value")
	test_while_loop()
	test_complex_logic(10, 20, 15)
	print("Tests complete!")


# Test 1: Simple conditional
func test_simple_condition() -> bool:
	if test_value > 0:
		return true
	else:
		return false


# Test 2: Nested conditions
func test_nested_conditions() -> String:
	if test_value > 100:
		if test_value > 200:
			return "very high"
		else:
			return "high"
	elif test_value > 50:
		return "medium"
	else:
		return "low"


# Test 3: Loop patterns
func test_loop_patterns() -> int:
	var count = 0
	
	for item in items:
		count += 1
		if item == "b":
			print("Found b!")
	
	return count


# Test 4: Early returns with validation
func test_early_returns(input: String) -> bool:
	if input.is_empty():
		return false
	
	if input.length() < 3:
		return false
	
	if not input.is_valid_identifier():
		return false
	
	return true


# Test 5: While loop example
func test_while_loop() -> void:
	var counter = 0
	
	while counter < 5:
		counter += 1
		print("Counter: ", counter)


# Test 6: Complex branching
func test_complex_logic(a: int, b: int, c: int) -> int:
	if a > b:
		if b > c:
			return a
		else:
			if a > c:
				return a
			else:
				return c
	else:
		if a > c:
			return b
		else:
			if b > c:
				return b
			else:
				return c
