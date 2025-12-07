extends Node
class_name Cutscene

@export var steps: Array[CutsceneAction] = []
@export var auto_start: bool = false
var running: bool = false

func _ready():
	if auto_start:
		play()
		
func play():
	if running:
		return
	running = true

	await run_steps()

	running = false

func play_and_free():
	await play()
	queue_free()

func run_steps():
	for step in steps:
		await step.execute(self)
