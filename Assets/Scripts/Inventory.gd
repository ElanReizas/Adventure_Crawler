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
