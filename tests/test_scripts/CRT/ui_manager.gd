extends CanvasLayer
class_name UIManager

## Manages all UI elements and updates

signal restart_pressed
signal quit_pressed

var health_bar: ProgressBar
var score_label: Label
var game_over_panel: Control

func _ready() -> void:
	setup_ui()

func setup_ui() -> void:
	create_health_bar()
	create_score_label()
	create_game_over_panel()

func create_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.max_value = 100
	add_child(health_bar)

func create_score_label() -> void:
	score_label = Label.new()
	add_child(score_label)

func create_game_over_panel() -> void:
	game_over_panel = Control.new()
	game_over_panel.visible = false
	add_child(game_over_panel)

func update_health(health: float) -> void:
	if health_bar:
		health_bar.value = health

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % score

func show_game_over_screen() -> void:
	if game_over_panel:
		game_over_panel.visible = true
	print("Game Over!")

func hide_game_over_screen() -> void:
	if game_over_panel:
		game_over_panel.visible = false

func show_notification(message: String) -> void:
	print("Notification: ", message)
