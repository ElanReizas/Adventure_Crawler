extends Weapon
class_name RangedWeapon

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 800.0
@export var spawn_offset: float = 20.0
@export var attack_cooldown: float = 0.5

func attack(attacker):
	enemy_cooldown(attacker, attacker.get_process_delta_time())
	if cooldown > 0:
		return

	# Enforce attack radius for ranged as well
	if attacker.is_in_group("enemies"):
		if attacker.global_position.distance_to(attacker.target.global_position) > attacker.attack_radius:
			return

	var direction: Vector2 = Vector2.ZERO

	if attacker.is_in_group("player"):
		var mouse_pos = attacker.get_global_mouse_position()
		direction = (mouse_pos - attacker.global_position).normalized()

	else:
		var targets = get_targets(attacker)
		if targets.is_empty():
			return
		var target = targets[0]
		direction = (target.global_position - attacker.global_position).normalized()


	var projectile = projectile_scene.instantiate()
	projectile.global_position = attacker.global_position + direction * spawn_offset
	projectile.rotation = direction.angle()
	projectile.direction = direction
	projectile.speed = projectile_speed
	projectile.weapon = self
	projectile.attacker = attacker 

	attacker.get_parent().add_child(projectile)
	
	if attacker.is_in_group("enemies"):
		cooldown = attack_cooldown
