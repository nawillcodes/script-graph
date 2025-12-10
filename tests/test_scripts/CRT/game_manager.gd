extends Node
class_name GameManager

## Main game controller that manages game state and coordinates systems

var player: Player
var ui_manager: UIManager
var current_level: int = 1

func _ready() -> void:
	start_game()

func start_game() -> void:
	print("Starting game...")
	spawn_player()
	initialize_ui()
	start_level(1)

func spawn_player() -> void:
	player = Player.new()
	player.health_changed.connect(_on_player_health_changed)
	add_child(player)

func initialize_ui() -> void:
	ui_manager = UIManager.new()
	add_child(ui_manager)

func start_level(level_number: int) -> void:
	current_level = level_number
	update_ui()

func update_ui() -> void:
	if player and ui_manager:
		ui_manager.update_health(player.health)
		ui_manager.update_score(player.score)

func _on_player_health_changed(new_health: float) -> void:
	update_ui()
	
	if new_health <= 0:
		handle_player_death()

func handle_player_death() -> void:
	print("Player died!")
	show_game_over()

func show_game_over() -> void:
	ui_manager.show_game_over_screen()

func restart_game() -> void:
	current_level = 1
	player.reset()
	start_game()

func quit_game() -> void:
	get_tree().quit()
