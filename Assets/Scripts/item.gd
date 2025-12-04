class_name Item
extends Resource


enum AllowedClass {
	ANY,      # both classes
	MELEE,    # melee-only
	RANGED    # ranged-only
}

@export var itemID: String
@export var itemName: String
@export var description: String
@export var rarity: String
@export var sprite: Texture2D

@export var slot: Inventory.Slot
@export var allowed_class: AllowedClass

# Stat modifiers applied later by stats.gd
@export var stat_changes: Dictionary[String, float]

func _to_string() -> String:
	return itemName

func setup(data: Dictionary) -> void:
	for key in data.keys():
		self.set(key, data[key])
