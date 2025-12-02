extends State


@onready var pivot = $"../../Pivot"
var can_transition: bool = false
func enter():
	super.enter()
	await play_animation("lasercharge")
	await play_animation("FiringMaLaser")
	
func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished
	
#set _target():
#	pivot.rotation = (owner.direction - pivot.position).angle()
