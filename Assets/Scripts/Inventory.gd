extends Resource
class_name Inventory

#im shrinking the size of the inventory for now, but we can scale it back later
enum Slot { WEAPON, HELMET, CHESTPLATE, LEGGINGS, BOOTS}

@export var slots: Array[Item] = [null, null, null, null, null]


func get_item(slot: Slot) -> Item:
	return slots[int(slot)]


func set_item(slot: Slot, item: Item) -> void:
	slots[int(slot)] = item


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
	var slot: Slot = item.slot
	if not can_equip(player, item):
		player.spawn_item_drop(item)
		return
	
	var existing = slots[int(slot)]

	if existing == null:
		set_item(slot, item)
		print_inv()
		player.apply_item_stats()
		return
	
	player.spawn_item_drop(existing)
	set_item(slot, item)
	print_inv()
	player.apply_item_stats()



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

func serialize_inv():
	var serialized_inv: Array = []
	for item in slots:
		if item == null:
			serialized_inv.append(null)
		else:
			serialized_inv.append(item.resource_path)
	return serialized_inv

func deserialize_inv(data: Array):
	for i in range(data.size()):
		var path = data[i]
		if path == null:
			slots[i] = null
		else:
			slots[i] = load(path) 

#gonna add a UI later. if a miracle happens
func print_inv():
	print("inventory array")
	for i in range(slots.size()):
		if slots[i] == null:
			print("Slot", i, ": EMPTY")
		else:
			print("Slot", i, ": ", slots[i].itemName, " (ID=", slots[i].itemID, ")", " Type: ", Slot.keys()[slots[i].slot])
