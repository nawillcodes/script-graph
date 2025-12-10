extends Node

## Test script with nested conditional statements

var health: int = 100
var mana: int = 50
var is_alive: bool = true


func check_status() -> String:
	if is_alive:
		if health > 75:
			if mana > 25:
				return "Excellent condition"
			else:
				return "Good health, low mana"
		elif health > 50:
			return "Moderate health"
		else:
			return "Low health"
	else:
		return "Dead"


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		health = 0
		is_alive = false
