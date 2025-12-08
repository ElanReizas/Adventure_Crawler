extends CharacterBody2D
class_name BasePlayer

@export_category("stats")
@export var speed: int = 300
@export var attack_damage: int = 10
@export var crit_rate: float = 0.2
@export var crit_damage: float = 2
@export var max_health: int = 100
var current_health: int

var base_speed: int
var base_attack_damage: int
var base_crit_rate: float
var base_crit_damage: float
var base_max_health: int

@export_category("other stuff")
@export var melee_attack_range: int = 100
@export var inventory: Inventory

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera_limiter: Area2D = $CameraLimiter
@onready var camera_2d: Camera2D = $Camera2D

var last_item_in_range: ItemDrop = null

@export var potions = 2

enum WeaponType { MELEE, RANGED }
@export var weapon_type: WeaponType = WeaponType.MELEE
var equipped_weapon: Weapon

const WEAPON_PATHS := {
	WeaponType.MELEE:  "res://Assets/Scenes/MeleeWeapon.tscn",
	WeaponType.RANGED: "res://Assets/Scenes/RangedWeapon.tscn"
}

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 800.0

var running_dialogue: bool = false

func init_player():
	add_to_group("player")
	# Ensure each player has their own Inventory resource
	if inventory == null:
		inventory = Inventory.new()
		
	base_speed = speed
	base_attack_damage = attack_damage
	base_crit_rate = crit_rate
	base_crit_damage = crit_damage
	base_max_health = max_health

		
	apply_item_stats()
	equip_weapon(WEAPON_PATHS[weapon_type])
	camera_limiter.area_entered.connect(_on_camera_limiter_area_entered)


func move_from_input(input_vector: Vector2, delta: float):
	#player movement can only come from input
	#knockback velocity is added on top so the player can be pushed even when not moving
	var move_velocity = input_vector * speed
	velocity = move_velocity + knockback_velocity
	#knockback velocity shrinks to 0 so that it doesnt permanently add onto player velocity
	if knockback_velocity.length() > 0:
		knockback_velocity = knockback_velocity.move_toward(
			Vector2.ZERO,
			knockback_decay * delta
		)

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
	#update_health_ui()

	if current_health <= 0:
		die()


func die():
	print("Player died!")
	if inventory:
		inventory.drop_entire_inventory(self)

	#Temporary delay in scene reload to see inventory drop for testing
	await get_tree().create_timer(5.0).timeout
	if not is_inside_tree():
		return

	var tree := get_tree()
	if tree:
		tree.reload_current_scene()


func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction.normalized() * force

#TODO: Rethink this 
func _process(_delta):
	if last_item_in_range and not is_instance_valid(last_item_in_range):
		last_item_in_range = null


func spawn_item_drop(item: Item) -> void:
	# Simple helper for "drop near feet"
	spawn_item_drop_at(item, global_position + Vector2(0, -16))


func spawn_item_drop_at(item: Item, pos: Vector2) -> void:
	var drop_scene := preload("res://Assets/Scenes/ItemDrop.tscn")
	var drop := drop_scene.instantiate()

	drop.item = item
	drop.global_position = pos

	get_tree().get_current_scene().add_child(drop)

func apply_item_stats():
	var final_speed = base_speed
	var final_attack_damage = base_attack_damage
	var final_crit_rate = base_crit_rate
	var final_crit_damage = base_crit_damage
	var final_max_health = base_max_health

	for item in inventory.slots:
		if item == null:
			continue
		for key in item.stat_changes.keys():
			var value = item.stat_changes[key]
			match key:
				"speed":
					final_speed += value
				"attack_damage":
					final_attack_damage += value
				"crit_rate":
					final_crit_rate += value
				"crit_damage":
					final_crit_damage += value
				"max_health":
					final_max_health += value
	speed = final_speed
	attack_damage = final_attack_damage
	crit_rate = final_crit_rate
	crit_damage = final_crit_damage

	var old_max_health = max_health
	max_health = final_max_health
	if current_health > max_health:
		current_health = max_health

func _on_camera_limiter_area_entered(area_2d: Area2D) -> void:
	if area_2d.has_node("Limit"):
		var collision_shape = area_2d.get_node("Limit")
		var size = collision_shape.shape.extents*2
		
		var view_size = get_viewport_rect().size
		if size.y < view_size.y:
			size.y = view_size.y
			
		if size.x < view_size.x:
			size.x = view_size.x
		camera_2d.limit_top = collision_shape.global_position.y - size.y/2
		camera_2d.limit_left = collision_shape.global_position.x - size.x/2
		camera_2d.limit_bottom = camera_2d.limit_top + size.y
		camera_2d.limit_right = camera_2d.limit_left + size.x
		
func use_potion():
	if potions <= 0:
		return

	potions -= 1
	current_health = min(current_health + 25, max_health)
