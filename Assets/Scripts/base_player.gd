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

func init_player():
	add_to_group("player")
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	equip_weapon(WEAPON_PATHS[weapon_type])

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
