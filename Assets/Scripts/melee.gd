extends State


func enter():
	super.enter()
	animation_player.play("SlashAttack")

func transition():
	#if too far, stop melee go back to follow
	if owner.direction.length() > 65:
		#Stop slash animation
		animation_player.play("RESET")
		get_parent().change_state("Follow")
		
func _process(delta):
	if (owner.direction.length() < 65):
	#continuously aim pivot at player from boss
		owner.get_node("Pivot").look_at(owner.player.global_position)
	
