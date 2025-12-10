extends Node

## Test script with empty blocks

var counter: int = 0


func update_counter(increment: bool) -> void:
	if increment:
		counter += 1
	else:
		pass  # ⚠️ Empty else block


func check_value(value: int) -> void:
	if value > 10:
		# ⚠️ Empty if block - no code here
		pass
	elif value < 0:
		print("Negative value")
	else:
		# ⚠️ Another empty block
		pass


func loop_test() -> void:
	for i in range(10):
		# ⚠️ Empty loop body
		pass
