extends State
class_name Melee

func enter():
	super.enter()
	
func transition():
	# 1. if too far, stop melee go back to follow
	if owner.direction.length() > 138:
		if not animation_player.is_playing():
			animation_player.play("RESET")
			get_parent().change_state("Follow")
		return
	# 2. if no target -> also go back to follow
	#continuously aim pivot at player from boss
	if (owner.target == null):
		if not animation_player.is_playing():
			animation_player.play("RESET")
			get_parent().change_state("Follow")
		return
	# 3. Melee + aim and slash
	owner.get_node("Pivot").look_at(owner.target.global_position)
	animation_player.play("SlashAttack")
	await animation_player.animation_finished
		
		
func melee():
	var hitbox = owner.get_node("Pivot/slashHitbox")
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(15)
