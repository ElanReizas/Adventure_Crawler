extends CharacterBody2D

class_name BasePlayer

@export var speed: int = 300
@export var melee_attack_range: int = 100
@export var attack_damage: int = 10

@export var crit_rate: float = 0.2
@export var crit_damage: float = 2

@export var max_health: int = 100
var current_health: int

@export var inventory: Inventory

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var last_item_in_range: ItemDrop = null


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
	
	if inventory == null:
		inventory = Inventory.new()
		
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
	drop_entire_inventory()
	
	# Small delay so i can see the items drop from inventory
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()
	
func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction.normalized() * force
	
	
func get_player_class() -> String:
	# Determines which class this player is based on weapon_type.
	if weapon_type == WeaponType.MELEE:
		return "melee"
	else:
		return "ranged"


func can_equip(item: Item) -> bool:
	match item.allowed_class:
		Item.AllowedClass.ANY:
			return true
		Item.AllowedClass.MELEE:
			return weapon_type == WeaponType.MELEE
		Item.AllowedClass.RANGED:
			return weapon_type == WeaponType.RANGED
	return false

	
func get_slot_from_item(item: Item) -> Inventory.Slot:
	match item.slotPiece:
		Item.SlotPiece.WEAPON:
			return Inventory.Slot.WEAPON
		Item.SlotPiece.HELMET:
			return Inventory.Slot.HELMET
		Item.SlotPiece.CHESTPLATE:
			return Inventory.Slot.CHESTPLATE
		Item.SlotPiece.LEGGINGS:
			return Inventory.Slot.LEGGINGS
		Item.SlotPiece.BOOTS:
			return Inventory.Slot.BOOTS
		Item.SlotPiece.RING:
			return Inventory.Slot.RING
		Item.SlotPiece.NECKLACE:
			return Inventory.Slot.NECKLACE

	push_error("Unknown slotPiece on item: " + item.itemName)
	return Inventory.Slot.WEAPON  # safe fallback

func get_slot_name(slot: Inventory.Slot) -> String:
	match slot:
		Inventory.Slot.WEAPON:
			return "Weapon"
		Inventory.Slot.HELMET:
			return "Helmet"
		Inventory.Slot.CHESTPLATE:
			return "Chestplate"
		Inventory.Slot.LEGGINGS:
			return "Leggings"
		Inventory.Slot.BOOTS:
			return "Boots"
		Inventory.Slot.RING:
			return "Ring"
		Inventory.Slot.NECKLACE:
			return "Necklace"
		_:
			return "Unknown"

func attempt_equip_item(item: Item) -> Dictionary:
	# Delegate to the inventory system to evaluate equip rules.
	var result: Dictionary = inventory.evaluate_equip(self, item)

	# Add player-facing information.
	# Nothing here modifies the inventory
	result["player_class"] = get_player_class()
	result["item_allowed_class"] = item.allowed_class

	# Return everything so UI or gameplay can decide what to do.
	return result
	
	

func drop_item_from_slot(slot: Inventory.Slot) -> void:
	var item: Item = inventory.get_item(slot)
	if item == null:
		return

	inventory.set_item(slot, null) # must clear FIRST
	spawn_item_drop(item)



func drop_item(item: Item) -> void:
	# Convenience: find the item's slot, then drop it
	for s in Inventory.Slot.values():
		if inventory.get_item(s) == item:
			drop_item_from_slot(s)
			return
	# If not found, do nothing


func spawn_item_drop(item: Item) -> void:
	var drop_scene := preload("res://Assets/Scenes/ItemDrop.tscn")
	var drop := drop_scene.instantiate()

	drop.item = item
	drop.global_position = global_position + Vector2(0, -16)

	get_tree().get_current_scene().add_child(drop)

	
func attempt_pickup_item(item: Item) -> void:
	# Ask the inventory what would happen if we tried to equip this
	var result: Dictionary = attempt_equip_item(item)

	var slot_index: int = result["slot"]
	var slot_name: String = get_slot_name(slot_index)
	# If this class cannot equip the item, reject it
	if not result["can_equip"]:
		print("Cannot equip:", item.itemName, "— class restriction")
		spawn_item_drop(item)
		return

	# If the slot is empty, equip immediately
	if result["slot_empty"]:
		inventory.set_item(result["slot"], item)
		print("Equipped:", item.itemName, "into slot:", slot_index, "\"" + slot_name + "\"")

		return

	# If slot is NOT empty, this means a swap choice is needed
	var existing: Item = result["existing_item"]

	

	print("Swap needed in slot:", slot_index, "\"" + slot_name + "\"")
	print("Current:", existing.itemName)
	print("New:", item.itemName)

	# TEMP TEST BEHAVIOR:
	# For now we auto-reject swap and drop the new item back on the ground
	spawn_item_drop(item)


func drop_entire_inventory() -> void:
	var radius := 60.0
	var angle_step := TAU / float(Inventory.Slot.size())
	var index := 0

	for slot in Inventory.Slot.values():
		var item: Item = inventory.get_item(slot)
		if item == null:
			continue

		# Clear slot BEFORE spawning (important for multiplayer safety)
		inventory.set_item(slot, null)

		# Calculate spread direction
		var angle := angle_step * index
		var offset := Vector2(cos(angle), sin(angle)) * radius

		spawn_item_drop_at(item, global_position + offset)

		index += 1


func spawn_item_drop_at(item: Item, world_position: Vector2) -> void:
	var drop_scene := preload("res://Assets/Scenes/ItemDrop.tscn")
	var drop := drop_scene.instantiate()

	drop.item = item
	drop.global_position = world_position

	get_tree().get_current_scene().add_child(drop)

	
func _process(_delta):
	if last_item_in_range and not is_instance_valid(last_item_in_range):
		last_item_in_range = null

	
