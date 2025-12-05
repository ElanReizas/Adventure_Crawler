extends Weapon
class_name MeleeWeapon

@export var attack_range: int = 100
@export var attack_cooldown: float = 0.4




func attack(attacker, direction: Vector2 = Vector2.ZERO):
	enemy_cooldown(attacker, attacker.get_process_delta_time())
	if cooldown > 0:
		return
		
	
	var potential_targets = get_targets(attacker)
	
	var valid_targets: Array = []
	
	for t in potential_targets:
		if attacker.global_position.distance_to(t.global_position) <= attack_range:
			valid_targets.append(t)
	
	if valid_targets	.is_empty():
		return
	
	if attacker.has_method("deal_damage"):
		attacker.deal_damage(self, direction, valid_targets)

	if attacker.is_in_group("enemies"):
		cooldown = attack_cooldown
	
	print("melee attack")
