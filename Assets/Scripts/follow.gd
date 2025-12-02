extends State

func enter():
	super.enter()
	owner.set_physics_process(true)
	
func exit():
	super.exit()
	owner.set_physics_process(false)
func transition():
	var distance = owner.direction.length()
	
	if distance < 138:
		#if target is close enough do this
		get_parent().change_state("Melee")
		#if player is too far dash to them
	elif distance > 200:
		get_parent().change_state("LaserBeam")
	elif distance > 300:
		get_parent().change_state("Dash")
