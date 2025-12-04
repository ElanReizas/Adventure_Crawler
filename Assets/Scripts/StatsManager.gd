class_name StatsManager
extends Node

var base_stats: Dictionary = {}
var equipment_modifiers: Array = []

func getStats() -> Dictionary:
	var final := base_stats.duplicate()
	
	for mod in equipment_modifiers:
		for key in mod.keys():
			final[key] = final.get(key, 0) + mod[key]
	
	
	return final
