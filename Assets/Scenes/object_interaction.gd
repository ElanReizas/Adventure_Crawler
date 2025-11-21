extends Node2D

@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"

func interaction():
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])

#future method to write for inventory
#func pickup();
