# player_movement.gd
extends CharacterBody2D
class_name Player

## Player controller with health, scoring, and movement

signal health_changed(new_health: float)
signal score_changed(new_score: int)
signal died

# Player properties
var health: float = 100.0
var max_health: float = 100.0
var score: int = 0
var high_score: int = 1000
var gravity: float = 980.0
var start_position: Vector2 = Vector2.ZERO

# Handles basic player movement and checks player health status
func _process(delta):
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # If health is depleted, handle player death
    if health <= 0:
        die()
    
    # Check for bonus rewards
    check_bonus()

# Resets player position and health upon death
func die():
    reset_position()
    health = max_health
    log_event("Player died")  # Log the death event

# A function that returns a value early
func test_early_return():
    if true:
        return 42
    return 0

# Checks if the player has beaten their high score to grant a bonus
func check_bonus():
    if score > high_score:
        grant_bonus()
        log_event("Bonus granted")  # Log the bonus event

# Increases the player's score as a bonus reward
func grant_bonus():
    score += 100

# Resets the player's position to the starting point
func reset_position():
    position = start_position

# Logs an event with a given message
func reset() -> void:
    health = max_health
    score = 0
    reset_position()

func take_damage(amount: float) -> void:
    health -= amount
    health_changed.emit(health)
    
    if health <= 0:
        die()

# Logs an event with a given message
func log_event(message: String):
    print("Event: " + message)
