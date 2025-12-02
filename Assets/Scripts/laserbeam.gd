extends State

#var locked_angle
@onready var pivot = $"../../Pivot"
var can_transition: bool = false
func enter():
	super.enter()
	await play_animation("lasercharge")
	await play_animation("FiringMaLaser")
	can_transition = true
	
func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished
	
func set_target():
	pivot.rotation = (owner.player.global_position - pivot.global_position).angle()


func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Dash")
