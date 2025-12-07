extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass




func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/pursuitVsWall.tscn")# Replace with function body.


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
