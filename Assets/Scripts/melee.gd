extends State
class_name Melee
var can_transition: bool = false
func enter():
	super.enter()
	animation_player.play("SlashAttack")
	await animation_player.animation_finished
	can_transition = true
	
func transition():
	if can_transition:
		can_transition = false
		return
	#if too far, stop melee go back to follow
	if owner.direction.length() > 120:
		#Stop slash animation
		animation_player.play("RESET")
		get_parent().change_state("Follow")
		
func _process(delta):
	if (owner.direction.length() < 138 && 
	owner.get_node("FiniteStateMachine").current_state is Melee):
	#continuously aim pivot at player from boss
		owner.get_node("Pivot").look_at(owner.player.global_position)
		
func melee():
	var hitbox = owner.get_node("Pivot/slashHitbox")
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(15)
