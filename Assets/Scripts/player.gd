extends CharacterBody2D

class_name Player

@export var speed: int = 400
@export var melee_attack_range: int = 200
@export var attack_damage: int = 10

@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@export var max_health: int = 100        # NEW
var current_health: int                  # NEW

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var equipped_weapon: Weapon


func _ready():
	add_to_group("player")

	current_health = max_health           # NEW
	_update_health_ui()                  # NEW (safe even if you have no UI yet)


func _physics_process(_delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector:
		velocity = input_vector * speed
	else:
		velocity = input_vector
	move_and_slide()

	if Input.is_action_just_pressed("attack") and equipped_weapon:
		equipped_weapon.attack(self)



# =============================
#   DAMAGE + DEATH SYSTEM
# =============================

# Called by Enemy hitbox
func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	print("Player took damage:", amount)

	_update_health_ui()

	if current_health <= 0:
		die()


func die():
	print("Player died!")
	queue_free()   # for now; later, respawn or game-over screen


# NEW: optional UI handler (safe even if no UI exists yet)
func _update_health_ui():
	var ui = get_node_or_null("HealthBar")
	if ui:
		ui.max_value = max_health
		ui.value = current_health
