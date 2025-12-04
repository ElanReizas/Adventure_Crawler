extends BasePlayer

class_name Player

func _ready():
	init_player()
	
func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	set_input_vector(input_vector)
	
	if equipped_weapon:
		var mouse_pos = get_global_mouse_position()
		attack_direction = (mouse_pos - global_position).normalized()

	super._physics_process(delta)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		var object: Object = ray_cast_2d.get_collider()
		if object and object.has_method("interaction"):
			object.interaction()
