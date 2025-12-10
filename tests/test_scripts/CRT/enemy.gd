extends CharacterBody2D
class_name Enemy

## Enemy AI that attacks the player and drops loot

signal enemy_died(loot_value: int)

var health: float = 50.0
var damage: float = 10.0
var loot_value: int = 100
var player_ref: Player = null
var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0

func _ready() -> void:
	find_player()

func find_player() -> void:
	# Would normally search scene tree
	print("Looking for player...")

func _process(delta: float) -> void:
	if player_ref:
		try_attack_player(delta)

func try_attack_player(delta: float) -> void:
	last_attack_time += delta
	
	if last_attack_time >= attack_cooldown:
		attack_player()
		last_attack_time = 0.0

func attack_player() -> void:
	if player_ref:
		player_ref.take_damage(damage)
		log_combat_event("Enemy attacked player")

func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	emit_loot()
	queue_free()

func emit_loot() -> void:
	enemy_died.emit(loot_value)
	spawn_loot_effects()

func spawn_loot_effects() -> void:
	# Visual effects would go here
	print("Spawning loot effects...")

func log_combat_event(message: String) -> void:
	print("Combat: ", message)
