extends Control

var selected_weapon: String = "melee"
var selected_mode: String = "single"


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass




func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Floor 1/1_Beginning_Borough.tscn")# Replace with function body.


func _on_weapon_type_pressed() -> void:
	pass # Replace with function body.


func _on_mutiplayer_pressed() -> void:
	pass # Replace with function body.


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/pursuitVsWall.tscn")


func _on_load_game_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_option_button_pressed() -> void:
	pass # Replace with function body.


func _on_option_button_item_selected(index: int) -> void:
	var selected_text = $"VBoxContainer/WeaponType/OptionButton".get_item_text(index)
	print("Selected:", selected_text)
	if selected_text == "melee":
		GameManager.player.weapon_type = GameManager.player.weapon_type.MELEE
