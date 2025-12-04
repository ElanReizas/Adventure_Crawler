class_name StatsManager
extends Node

var base_stats: Dictionary = {}
var equipment_modifiers: Array = []

func getStats() -> Dictionary:
	var final := base_stats.duplicate()
	
	# for every modifier in the array, change the according stat
	for mod in equipment_modifiers:
		for key in mod.keys():
			# add the modifier to the stat
			final[key] = final.get(key, 0) + mod[key]
	
	
	return final
