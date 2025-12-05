extends Node2D
var player: BasePlayer = null

var dead_enemies: Dictionary = {}

#This has singleplayer in mind. 

# When player is being passed as an input, it's called p. Good variable naming? No?
# Save_player_state is called before changing scenes. It will be invoked on save files later.

var player_data: Dictionary = {
	"health": null,
	"max_health": null,
	"weapon_type": null,
	"inventory": null,
}

func register_player(p):
	player = p

func save_player_state():
	if player == null:
		return

	player_data.health = player.current_health
	player_data.max_health = player.current_stats.get("max_hp")
	player_data.weapon_type = player.weapon_type
	player_data.inventory = player.inventory.duplicate()
	
	print("Saved via GameManager:",
		" health=", player_data.health,
		" max_health=", player_data.max_health,
		" weapon_type=", player_data.weapon_type,
		" inventory=", player_data.inventory)

func load_player_state(p: BasePlayer):
	if p == null:
		return

	if player_data.max_health != null:
		p.max_health = player_data.max_health

	if player_data.health != null:
		p.current_health = player_data.health
	else:
		# Theres no saved health value, start fully healed.
		p.current_health = p.current_health
	if player_data.weapon_type != null:
		p.weapon_type = player_data.weapon_type

	if player_data.inventory != null:
		p.inventory = player_data.inventory.duplicate()


func mark_enemy_dead(enemy_id: String):
	dead_enemies[enemy_id] = true
	print("enemy is marked dead:", enemy_id)

func is_enemy_dead(enemy_id: String) -> bool:
	return dead_enemies.has(enemy_id)

const SAVE_PATH := "user://savegame.json"

# these functions can be called at any point you want to save or load from a save file. (ie, on exiting)
func save_to_file():
	var save_dict = {
		"player_data": player_data,
		"dead_enemies": dead_enemies,
	}

	var json_text = JSON.stringify(save_dict, "\t")

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_text)

	print("Game saved to:", SAVE_PATH)


func load_from_file():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()

	var result = JSON.parse_string(json_text)

	# pull JSON fields from file into GameManager
	# TODO: use ID to rebuild the inventories entries since JSON only stores simple data types
	player_data = result["player_data"]
	dead_enemies = result["dead_enemies"]
