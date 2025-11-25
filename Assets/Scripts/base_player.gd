extends CharacterBody2D

class_name BasePlayer

@export var speed: int = 300
@export var melee_attack_range: int = 100
@export var attack_damage: int = 10

@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@export var max_health: int = 100
var current_health: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

enum WeaponType { MELEE, RANGED }
@export var weapon_type: WeaponType = WeaponType.MELEE
var equipped_weapon: Weapon
const WEAPON_PATHS := {
	WeaponType.MELEE:  "res://Assets/Scenes/MeleeWeapon.tscn",
	WeaponType.RANGED: "res://Assets/Scenes/RangedWeapon.tscn"
}

@onready var health_bar: ProgressBar = $HealthBar

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 800.0

enum PlayerState { IDLE, MOVE, DODGE, ATTACK }
var state: PlayerState = PlayerState.IDLE
@export var dodge_speed: float = 800.0
@export var dodge_time: float = 0.4
@export var current_dodge_time: float = 0.0

var input_vector := Vector2.ZERO
var attack_direction := Vector2.ZERO

func init_player():
	add_to_group("player")
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	equip_weapon(WEAPON_PATHS[weapon_type])

# Take Input Passed from Player
func set_input_vector(v: Vector2) -> void:
	input_vector = v

func _physics_process(delta: float) -> void:
	handle_state(delta)
	move_and_slide()
	
	
# Handle Player State (e.g dodge, attack, etc.)
# This allows for future implementation of different movement states like Stunned, Frozen, Asleep, etc.
func handle_state(delta: float) -> void:
	match state:
		
		PlayerState.IDLE:
			if Input.is_action_just_pressed("attack"):
				start_attack()
			elif Input.is_action_just_pressed("dodge"):
				start_dodge()
			elif input_vector != Vector2.ZERO:
				state = PlayerState.MOVE
			
			velocity = Vector2.ZERO
		
		PlayerState.MOVE:
			if Input.is_action_just_pressed("attack"):
				start_attack()
			elif Input.is_action_just_pressed("dodge"):
				start_dodge()
			elif input_vector == Vector2.ZERO:
				state = PlayerState.IDLE

			velocity = input_vector * speed
		PlayerState.DODGE:
			current_dodge_time += delta

			if current_dodge_time >= dodge_time:
				state = PlayerState.IDLE
				velocity = Vector2.ZERO


		PlayerState.ATTACK:
			velocity = Vector2.ZERO

			if not animation_player.is_playing():
				state = PlayerState.IDLE
		
			

# Start of All Movement State Functions

#Attack
func start_attack():
	state = PlayerState.ATTACK
	
	if equipped_weapon:
		equipped_weapon.attack(self, attack_direction)
	
	animation_player.play("attack")

#Dodge
func start_dodge():
	state = PlayerState.DODGE
	current_dodge_time = 0.0
	
	if input_vector == Vector2.ZERO:
		velocity = Vector2.LEFT * dodge_speed
	else:
		velocity = input_vector * dodge_speed
	
	animation_player.play("roll")

# End of All Movement State Functions

func move_from_input(input_vector: Vector2, delta: float):
	#player movement can only come from input
	#knockback velocity is added on top so the player can be pushed even when not moving
	var move_velocity = input_vector * speed
	velocity = move_velocity + knockback_velocity
	#knockback velocity shrinks to 0 so that it doesnt permanently add onto player velocity
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		
	if input_vector.length() > 0:
		var move_direction =  input_vector.normalized()
		ray_cast_2d.target_position = move_direction * 32

	move_and_slide()

func equip_weapon(path: String) -> void:
	if equipped_weapon != null:
		equipped_weapon.queue_free()
	var scene: PackedScene = load(path)
	var weapon_instance: Weapon = scene.instantiate()
	add_child(weapon_instance)
	equipped_weapon = weapon_instance


func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()
		
func die():
	print("Player died!")
	get_tree().reload_current_scene()
	
func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction.normalized() * force
