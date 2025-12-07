extends CutsceneAction
class_name WaitAction

@export var duration: float = 1.0

func execute(runner):
	await runner.get_tree().create_timer(duration).timeout
