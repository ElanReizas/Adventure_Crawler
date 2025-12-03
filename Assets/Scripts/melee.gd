extends State
class_name Melee
var can_transition: bool = false

func enter():
	super.enter()
	can_transition = false
	await play_animation("SlashAttack")
	can_transition = true
	
func transition():
		#if too far, stop melee go back to follow
		if owner.direction.length() > 138:
			#Stop slash animation
			animation_player.play("RESET")
			get_parent().change_state("Follow")
		
func _process(delta):
	if (owner.direction.length() < 138 && 
	owner.get_node("FiniteStateMachine").current_state is Melee):
	#continuously aim pivot at player from boss
		owner.get_node("Pivot").look_at(owner.target.global_position)
		
func melee():
	var hitbox = owner.get_node("Pivot/slashHitbox")
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(15)
func play_animation(anim_name):
	animation_player.play(anim_name)
	await animation_player.animation_finished
