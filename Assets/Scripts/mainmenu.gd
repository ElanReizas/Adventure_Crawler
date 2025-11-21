extends Control
@export var new_run: Button
@export var options: Button
@export var stats: Button

@export var start_scene: String

func _ready():
	new_run.pressed.connect(_on_new_run_pressed)
	
func _on_new_run_pressed():
	get_tree().change_scene_to_file.call_deferred(start_scene)
