extends Weapon
class_name MeleeWeapon

@export var attack_range: int = 100
@export var attack_cooldown: float = 0.4


func attack(attacker, direction: Vector2 = Vector2.ZERO):
	enemy_cooldown(attacker, attacker.get_process_delta_time())
	if cooldown > 0:
		return

	for target in get_targets(attacker):
		if attacker.global_position.distance_to(target.global_position) <= attack_range:
			target.take_damage(calculate_damage(attacker))
			if attacker.is_in_group("enemies"):
				cooldown = attack_cooldown
	print("melee attack")
