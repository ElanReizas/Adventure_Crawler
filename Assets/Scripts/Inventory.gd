extends Resource
class_name Inventory

# Fixed equipment slot list.
enum Slot { WEAPON, HELMET, CHESTPLATE, LEGGINGS, BOOTS, RING, NECKLACE }

# Dictionary storing items by slot.
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
	# Returns whatever item is currently in this slot (or null).
	return slots[slot]


func set_item(slot: Slot, item: Item) -> void:
	# overwrites the slot with the given item.
	# Higher-level gameplay will call this AFTER confirming swaps.
	slots[slot] = item
	
func evaluate_equip(player: Node, item: Item) -> Dictionary:

	# Determine which Inventory.Slot this item goes into.
	var slot: Slot = player.get_slot_from_item(item)

	# Check class restrictions (BasePlayer.can_equip)
	var class_ok: bool = player.can_equip(item)

	# Check if the slot is empty
	var existing_item: Item = slots[slot] if slots.has(slot) else null
	
	# true if slot has no item
	var is_empty: bool = (existing_item == null)
	
	#Return info as dictionary
	return {
		"slot": slot,
		"can_equip": class_ok,
		"slot_empty": is_empty,
		"existing_item": existing_item
	}
