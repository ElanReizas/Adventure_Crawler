extends Resource
class_name Inventory

enum Slot { WEAPON, HELMET, CHESTPLATE, LEGGINGS, BOOTS, RING, NECKLACE }

# Dictionary storing items by slot
@export var slots := {
	Slot.WEAPON: null,
	Slot.HELMET: null,
	Slot.CHESTPLATE: null,
	Slot.LEGGINGS: null,
	Slot.BOOTS: null,
	Slot.RING: null,
	Slot.NECKLACE: null
}


func get_item(slot: Slot) -> Item:
	return slots[slot]


func set_item(slot: Slot, item: Item) -> void:
	slots[slot] = item


func can_equip(player: BasePlayer, item: Item) -> bool:
	match item.allowed_class:
		Item.AllowedClass.ANY:
			return true
		Item.AllowedClass.MELEE:
			return player.weapon_type == BasePlayer.WeaponType.MELEE
		Item.AllowedClass.RANGED:
			return player.weapon_type == BasePlayer.WeaponType.RANGED
	return false


func evaluate_equip(player: BasePlayer, item: Item) -> Dictionary:
	
	var slot: Slot = item.slot                           
	var class_ok: bool = can_equip(player, item)
	var existing: Item = slots[slot]
	var empty: bool = (existing == null)

	return {
		"slot": slot,
		"can_equip": class_ok,
		"slot_empty": empty,
		"existing_item": existing
	}


func attempt_pickup(player: BasePlayer, item: Item) -> void:
	var result := evaluate_equip(player, item)

	var slot: Slot = result["slot"]
	var slot_index: int = int(slot)

	# keys() returns Array, so keep it untyped and cast when we read from it
	var all_slot_names: Array = Slot.keys()
	var slot_name: String = String(all_slot_names[slot_index])

	if not result["can_equip"]:
		# Class restriction failed – drop it back on the ground
		player.spawn_item_drop(item)
		return

	if result["slot_empty"]:
		set_item(slot, item)
		print("Equipped:", item.itemName, "into slot:", slot_index, "\"" + slot_name + "\"")
		return

	var existing: Item = result["existing_item"]

	print("Swap needed in slot:", slot_name)
	print("Current:", existing.itemName)
	print("New:", item.itemName)

	# For now, auto-reject swap and drop the new item
	player.spawn_item_drop(item)


func drop_item_from_slot(player: BasePlayer, slot: Slot) -> void:
	var item := get_item(slot)
	if item == null:
		return

	set_item(slot, null)
	player.spawn_item_drop(item)


func drop_entire_inventory(player: BasePlayer) -> void:
	var radius := 60.0
	var angle_step := TAU / float(Slot.keys().size())
	var index := 0

	for slot in Slot.values():
		var item := get_item(slot)
		if item == null:
			continue

		set_item(slot, null)

		var angle := angle_step * index
		var offset := Vector2(cos(angle), sin(angle)) * radius

		# Use deferred spawn to avoid physics "flushing queries"
		player.call_deferred("spawn_item_drop_at", item, player.global_position + offset)
		index += 1
