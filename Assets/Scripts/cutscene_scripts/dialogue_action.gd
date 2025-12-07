extends CutsceneAction
class_name DialogueAction

@export var dialogue: DialogueResource
@export var start_id: String = "start"

func execute(runner):
	DialogueManager.show_dialogue_balloon(dialogue, start_id)
	await DialogueManager.dialogue_ended
