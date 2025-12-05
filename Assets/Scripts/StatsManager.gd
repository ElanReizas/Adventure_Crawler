class_name StatsManager
extends Node

var base_stats: Dictionary = {}
var equipment_modifiers: Dictionary = {}

func update_equipment_modifiers(inventory: Inventory):
	equipment_modifiers.clear()
	
	for slot in inventory.slots.values():
		if slot != null:
			var item: Item = slot
			
			for key in item.stat_changes.keys():
				equipment_modifiers[key] = equipment_modifiers.get(key, 0) + item.stat_changes[key]

func getStats() -> Dictionary:
	var final := base_stats.duplicate()
	
	# for every modifier in the array, change the according stat
	for key in equipment_modifiers.keys():
		final[key] = final.get(key, 0) + equipment_modifiers[key]
	
	
	return final
