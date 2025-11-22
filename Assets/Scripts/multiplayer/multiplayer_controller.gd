extends CharacterBody2D

class_name MultiplayerPlayer

@export var player_id := 1:
	set(id):
		player_id = id
		# This makes the given peer (client) the authority over the input node
		%InputSynchronizer.set_multiplayer_authority(id)

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
var weapon_type: WeaponType = WeaponType.MELEE
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

	if player_id == 1:
		weapon_type = WeaponType.RANGED
	else:
		weapon_type = WeaponType.MELEE
		
	set_player_graphics()
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	equip_weapon(WEAPON_PATHS[weapon_type])

	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	# we read the input from multiplayer_input instead
	var input_vector: Vector2 = %InputSynchronizer.input_vector

	#player movement can only come from input
	#knockback velocity is added on top so the player can be pushed even when not moving
	var move_velocity = input_vector * speed
	velocity = move_velocity + knockback_velocity
	#knockback velocity shrinks to 0 so that it doesnt permanently add onto player velocity
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

	if input_vector.length() > 0:
		var direction = input_vector.normalized()
		ray_cast_2d.target_position = direction * 32

	move_and_slide()

	if %InputSynchronizer.attack_pressed and equipped_weapon:
		rpc("network_attack", %InputSynchronizer.aim_direction)

	if %InputSynchronizer.interact_pressed:
		interaction()

@rpc("any_peer", "call_local")
func network_attack(direction: Vector2):
	if equipped_weapon:
		equipped_weapon.attack(self, direction)


func interaction() -> void:
	var object: Object = ray_cast_2d.get_collider()
	if object and object.has_method("interaction"):
		object.interaction()

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

#we'll change this routine to generally handle player appearances
func set_player_graphics():
	var sprite1 = $Sprite2D_Player1
	var sprite2 = $Sprite2D_Player2
	if player_id == 1:
		sprite1.visible = true
		sprite2.visible = false
	else:
		sprite1.visible = false
		sprite2.visible = true
