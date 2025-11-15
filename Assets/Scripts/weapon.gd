extends Node
class_name Weapon

@export var attack_damage: int = 10
@export var crit_rate: float = 0.2
@export var crit_damage: float = 2.0

func calculate_damage(player: Node) -> int:
	var damage = attack_damage
	if randf() < crit_rate:
		var anim = player.get_node("AnimationPlayer")
		anim.play("crit")
		damage *= crit_damage
		print("CRIT!")
	return damage
	
func attack(player):
	pass
