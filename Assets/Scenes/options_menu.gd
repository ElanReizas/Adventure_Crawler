extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_key_bindings_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/input_settings/input_settings.tscn")


func _on_audio_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/audio_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
