class_name Item
extends Resource
@export var itemID: String
@export var itemName: String
@export var description: String
@export var rarity: String
@export var sprite: Texture2D
@export var slotPiece: String
#hashmap to contain a list of the items stat changes String Key statname, value statamount
@export var stat_changes: Dictionary[String, float]

func _to_string() -> String:
	return itemName
