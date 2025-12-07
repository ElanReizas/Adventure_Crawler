extends Node2D

# This script sets up things that should be true on a per-level basis. 
# In the (preferably very near) future we can add background music etc.

func _ready():
	if DialogueManager:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(balloon):
	if GameManager.player:
		GameManager.player.running_dialogue = true
		
func _on_dialogue_ended(balloon):
	if GameManager.player:
		GameManager.player.running_dialogue = false
