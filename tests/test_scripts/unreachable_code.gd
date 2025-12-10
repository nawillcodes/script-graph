extends Node

## Test script with unreachable code after return

func calculate_score(points: int) -> int:
	if points > 100:
		return 100
	
	return points
	
	# ⚠️ This code is unreachable
	print("This will never execute")
	points += 10


func process_item(item: String) -> void:
	if item == "special":
		print("Processing special item")
		return
		print("This is unreachable")  # ⚠️ Unreachable
	
	print("Processing normal item")
