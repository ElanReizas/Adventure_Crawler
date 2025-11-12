extends Area2D

@export var new_scene: String

func _ready():
	self.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is Player:
		get_tree().change_scene_to_file.call_deferred(new_scene)
