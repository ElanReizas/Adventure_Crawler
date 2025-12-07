extends State
@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"

func enter():
	super.enter()
	animation_player.play("bossdeath")
	await animation_player.animation_finished
	animation_player.play("RatKingDefeat")
	DialogueManager.show_dialogue_balloon(load("res://Assets/DialogueFiles/testing.dialogue"), "boss_defeat")
