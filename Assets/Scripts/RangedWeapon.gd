extends Weapon
class_name RangedWeapon

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 800.0
@export var spawn_offset: float = 20.0

func attack(player):
	var mouse_pos = player.get_global_mouse_position()
	var direction = (mouse_pos - player.global_position).normalized()

	var projectile = projectile_scene.instantiate()
	projectile.global_position = player.global_position + direction * spawn_offset
	projectile.rotation = direction.angle()
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.weapon = self
	projectile.player = player 

	player.get_parent().add_child(projectile)
