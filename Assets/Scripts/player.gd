extends BasePlayer
class_name Player




func _ready():
	init_player()
	GameManager.register_player(self)
	GameManager.load_player_state(self)



func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	move_from_input(input_vector, delta)

	if Input.is_action_just_pressed("attack") and equipped_weapon:
		var mouse_pos = get_global_mouse_position()
		var aim_direction = (mouse_pos - global_position).normalized()
		equipped_weapon.attack(self, aim_direction)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):

		# Priority 1: world object interaction (NPCs, shops, doors, etc.)
		var object: Object = ray_cast_2d.get_collider()
		if object and object.has_method("interaction"):
			object.interaction()
			return

		# Priority 2: item pickup
		if last_item_in_range:
			last_item_in_range.pickup(self)
			return
