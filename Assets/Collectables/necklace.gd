class_name NecklaceItem
extends Item

func _init():
	setup({
				"itemID": "necklace_001",
		"itemName": "Gold Necklace",
		"description": "A finely crafted magical necklace.",
		"rarity": "Rare",
		"sprite": preload("res://Assets/Images/Necklace.png"),
		"slot": Inventory.Slot.NECKLACE,
		"allowed_class": AllowedClass.ANY,
		"stat_changes": {
			"mana_regen": 5.0,
			"magic_defense": 2.0
		}
	})
