class_name Item
extends Resource

@export var itemID: String
@export var itemName: String
@export var description: String
@export var rarity: String
@export var sprite: Texture2D


enum SlotPiece {
	WEAPON,
	HELMET,
	CHESTPLATE,
	LEGGINGS,
	BOOTS,
	RING,
	NECKLACE
}

enum AllowedClass {
	ANY,      # both classes
	MELEE,    # melee-only
	RANGED    # ranged-only
}

@export var slotPiece: SlotPiece = SlotPiece.WEAPON
@export var allowed_class: AllowedClass = AllowedClass.ANY


#hashmap to contain a list of the items stat changes String Key statname, value statamount
@export var stat_changes: Dictionary[String, float]

func _to_string() -> String:
	return itemName
