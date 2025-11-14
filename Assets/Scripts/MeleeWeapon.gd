extends Weapon
class_name MeleeWeapon

@export var attack_range: int = 200

func attack(player):
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		if player.position.distance_to(enemy.position) <= attack_range:
			var final_damage = calculate_damage(player)
			enemy.take_damage(final_damage)
