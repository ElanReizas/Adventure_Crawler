extends State

var can_transition: bool = false
var offset := 80.0  # distance to stop short

func enter():
	super.enter()
	#visual for dash?
	await dash()
	can_transition = true
func dash():
	var direction = (owner.target.global_position - owner.global_position).normalized()
	var target_pos = owner.target.global_position - direction * offset
	var tween = create_tween()
	tween.tween_property(owner, "position", target_pos, 1.0)
	await tween.finished
func transition():
	if can_transition:
		can_transition = false
		get_parent().change_state("Follow")
