extends State


func enter():
	super.enter()
	
	# STOP ALL MOVEMENT
	owner.set_physics_process(false)
	owner.velocity = Vector2.ZERO
	animation_player.play("SlashAttack")

func transition():
	#if too far, stop melee go back to follow
	if owner.direction.length() > 55:
		animation_player.play("RESET")
		get_parent().change_state("Follow")
