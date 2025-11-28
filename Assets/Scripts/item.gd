class_name Item
extends Resource

@export var itemID: String
@export var itemName: String
@export var description: String
@export var rarity: String
@export var sprite: Texture2D

@export var slot: Inventory.Slot = Inventory.Slot.WEAPON

enum AllowedClass {
	ANY,      # both classes
	MELEE,    # melee-only
	RANGED    # ranged-only
}

@export var allowed_class: AllowedClass = AllowedClass.ANY

# Stat modifiers applied later by stats.gd
@export var stat_changes: Dictionary[String, float]

func _to_string() -> String:
	return itemName
