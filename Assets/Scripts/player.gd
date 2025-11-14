extends CharacterBody2D

class_name Player

@export var speed: int = 400
@export var dodge_speed: int = 800
@export var dodge_time: float = 0.5
var current_dodge_time: float = 0
@export var dodge_duplicate_time: float = 0.05
var current_dodge_duplicate_time: float = 0
@export var duplicate_life_time: float = 0.3
var is_dodging = false

@export var melee_attack_range: int = 200
@export var attack_damage: int = 10

# for now, these crit values are hardcoded
# in the future we may add items which correspond to crit values
@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	#added player to group of players to be referenced by external scripts
	add_to_group("player")
func _physics_process(_delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if !is_dodging && Input.is_action_just_pressed("dodge"):
		is_dodging = true
		current_dodge_time = 0
		
		if input_vector == Vector2.ZERO:
			velocity = Vector2.LEFT * dodge_speed
		else:
			velocity = input_vector * dodge_speed
	if is_dodging:
		current_dodge_time += _delta

		velocity = velocity.lerp(Vector2.ZERO, 0.1)

		if current_dodge_time >= dodge_time:
			is_dodging = false
	elif input_vector != Vector2.ZERO:
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
			
	
			
	
		
	
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
