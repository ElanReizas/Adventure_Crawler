class_name BaseCollectableEntity
extends Area2D

func _ready():
	connect("body_entered", on_body_entered)
	
	
	
func on_body_entered(body: CharacterBody2D) -> void:
	
	if not body.is_in_group()
	
