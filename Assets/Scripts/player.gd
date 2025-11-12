extends CharacterBody2D

class_name Player

@export var speed: int = 400
@export var melee_attack_range: int = 200
@export var attack_damage: int = 10

# for now, these crit values are hardcoded
# in the future we may add items which correspond to crit values
@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer


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
	if Input.is_action_just_pressed("attack"):
		attack()
	
func attack():
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if position.distance_to(enemy.position) <= melee_attack_range:
				var damage = attack_damage
				if randf() < crit_rate:
					damage *= crit_damage
					animation_player.play("crit")
					print("CRIT!!!!")
					
				enemy.take_damage(damage)
