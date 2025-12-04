extends State

var can_transition: bool = false

func enter():
	super.enter()
	#visual for dash?
	await dash()
	can_transition = true
func dash():
	var tween = create_tween()
	tween.tween_property(owner, "position", owner.target.global_position, 0.8)
	await tween.finished
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
