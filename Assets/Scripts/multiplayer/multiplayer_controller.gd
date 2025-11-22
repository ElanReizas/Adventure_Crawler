extends BasePlayer

class_name MultiplayerPlayer

@export var player_id := 1:
	set(id):
		player_id = id
		# This makes the given peer (client) the authority over the input node
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	
	if player_id == 1:
		weapon_type = WeaponType.RANGED
	else:
		weapon_type = WeaponType.MELEE
	init_player()
	set_player_graphics()
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	# we read the input from multiplayer_input instead
	var input_vector: Vector2 = %InputSynchronizer.input_vector
	move_from_input(input_vector, delta)
	if %InputSynchronizer.attack_pressed and equipped_weapon:
		rpc("network_attack", %InputSynchronizer.aim_direction)

	if %InputSynchronizer.interact_pressed:
		interaction()

@rpc("any_peer", "call_local")
func network_attack(direction: Vector2):
	if equipped_weapon:
		equipped_weapon.attack(self, direction)

func interaction() -> void:
	var object: Object = ray_cast_2d.get_collider()
	if object and object.has_method("interaction"):
		object.interaction()

#we'll change this routine to generally handle player appearances
func set_player_graphics():
	var sprite1 = $Sprite2D_Player1
	var sprite2 = $Sprite2D_Player2
	if player_id == 1:
		sprite1.visible = true
		sprite2.visible = false
	else:
		sprite1.visible = false
		sprite2.visible = true
