extends Node
class_name Weapon

@export var attack_damage: int = 10
@export var crit_rate: float = 0.2
@export var crit_damage: float = 2.0
var cooldown: float = 0.0 


func get_modifiers() -> Dictionary:
	return {
		"attack_damage": attack_damage,
		"crit_rate": crit_rate,
		"crit_multiplier": crit_damage
	}
	

func calculate_damage(attacker: Node) -> int:
	var damage = attack_damage
	if randf() < crit_rate:
		#var anim = player.get_node("AnimationPlayer")
		#anim.play("crit")
		damage *= crit_damage
		print("CRIT!")
	return damage

func get_targets(attacker: Node) -> Array:
	if attacker.is_in_group("player"):
		return attacker.get_tree().get_nodes_in_group("enemies")
	else:
		return attacker.get_tree().get_nodes_in_group("player")

#theres a direction parameter here, but by default its 0 so melee ignores it
func attack(attacker: Node, direction: Vector2 = Vector2.ZERO):
	pass

func enemy_cooldown(attacker: Node, delta: float) -> void:
	if attacker.is_in_group("enemies"):
		cooldown -= max(cooldown - delta, 0)
