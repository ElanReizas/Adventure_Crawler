extends CharacterBody2D

class_name Player

@export var speed: int = 300
@export var melee_attack_range: int = 100
@export var attack_damage: int = 10

@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@export var max_health: int = 100
var current_health: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer


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

func _ready():
	add_to_group("player")
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	equip_weapon(WEAPON_PATHS[weapon_type])

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	#player movement can only come from input
	#knockback velocity is added on top so the player can be pushed even when not moving
	var move_velocity = input_vector * speed
	velocity = move_velocity + knockback_velocity
	#knockback velocity shrinks to 0 so that it doesnt permanently add onto player velocity
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

	move_and_slide()

	if Input.is_action_just_pressed("attack") and equipped_weapon:
		equipped_weapon.attack(self)


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
