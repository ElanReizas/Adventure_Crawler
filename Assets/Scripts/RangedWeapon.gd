extends Weapon
class_name RangedWeapon

@export var projectile_scene: PackedScene
@export var bomb_scene: PackedScene
@export var projectile_speed: float = 800.0
@export var spawn_offset: float = 20.0
@export var attack_cooldown: float = 0.5
enum ProjectileType { BULLET, BOMB }
@onready var ranged_type: ProjectileType = ProjectileType.BULLET
func attack(attacker, direction: Vector2 = Vector2.ZERO):
	enemy_cooldown(attacker, attacker.get_process_delta_time())
	if cooldown > 0:
		return
	if ranged_type == ProjectileType.BULLET:
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
