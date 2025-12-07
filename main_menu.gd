extends CanvasGroup

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/pursuitVsWall.tscn")


func _on_save_game_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/options_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
	
func on_exit_options_menu() -> void:
	pass

	
	
