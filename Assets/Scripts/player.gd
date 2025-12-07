extends BasePlayer
class_name Player
var is_attacking = false
func _ready():
	GameManager.register_player(self)
	GameManager.load_player_state(self)
	init_player()


func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	move_from_input(input_vector, delta)

	if Input.is_action_just_pressed("attack") and equipped_weapon and not is_attacking:
		is_attacking = true
		var mouse_pos = get_global_mouse_position()
		var aim_direction = (mouse_pos - global_position).normalized()
		if equipped_weapon is MeleeWeapon:
			get_node("Pivot").look_at(mouse_pos)
			animation_player.play("normalSlash")
			await animation_player.animation_finished
		equipped_weapon.attack(self, aim_direction)
		is_attacking = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and not running_dialogue:

		# Priority 1: world object interaction (NPCs, shops, doors, etc.)
		for object in interaction_area.get_overlapping_bodies():
			if object and object.has_method("interaction"):
				object.interaction()
				return

		# Priority 2: item pickup
		if last_item_in_range:
			last_item_in_range.pickup(self)
			return
