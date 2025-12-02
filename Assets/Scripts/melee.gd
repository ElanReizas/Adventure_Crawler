extends State


func enter():
	super.enter()
	animation_player.play("SlashAttack")
func transition():
	#if too far, stop melee go back to follow
	if owner.direction.length() > 30:
		get_parent().change_state("Follow")
