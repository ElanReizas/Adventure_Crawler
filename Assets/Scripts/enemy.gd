extends Node2D
class_name Enemy
var max_health: int = 100
var current_health: int
@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()

func die():
	queue_free()
