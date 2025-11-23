extends MultiplayerSynchronizer

@onready var player = $".."

var input_vector: Vector2 = Vector2.ZERO
var attack_pressed: bool = false
var interact_pressed: bool = false
var aim_direction: Vector2 = Vector2.ZERO

func _ready():
	# disables local processing for non-authority
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(delta):
	input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	attack_pressed = Input.is_action_just_pressed("attack")
	interact_pressed = Input.is_action_just_pressed("interaction")

	# only players need aiming
	if player.equipped_weapon is RangedWeapon:
		aim_direction = (player.get_global_mouse_position() - player.global_position).normalized()
	else:
		aim_direction = Vector2.ZERO
