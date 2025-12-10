extends Node

## Test script with various loop types

var items: Array = ["apple", "banana", "cherry"]
var counter: int = 0


func process_all_items() -> void:
	for item in items:
		print("Processing: ", item)
		if item == "banana":
			print("Found banana!")


func count_to_ten() -> void:
	for i in range(10):
		counter += 1
		print("Count: ", counter)


func while_loop_example() -> void:
	var running: bool = true
	var iterations: int = 0
	
	while running:
		iterations += 1
		print("Iteration: ", iterations)
		
		if iterations >= 5:
			running = false


func nested_loops() -> void:
	for x in range(3):
		for y in range(3):
			print("Position: ", x, ",", y)
