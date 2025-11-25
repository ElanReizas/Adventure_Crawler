class_name Item
extends Resource

@export var itemID: String
@export var itemName: String
@export var description: String
@export var rarity: String
@export var sprite: Texture2D
@export var slotPiece: String


#who can equip item:
#   "any"    -> both classes can equip
#   "melee"  -> only sword/melee characters
#   "ranged" -> only bow/ranged characters
@export var allowed_class: String = "any"


#hashmap to contain a list of the items stat changes String Key statname, value statamount
@export var stat_changes: Dictionary[String, float]

func _to_string() -> String:
	return itemName
