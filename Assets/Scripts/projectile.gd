extends Area2D
class_name Projectile

@export var speed: float = 800.0
@export var weapon: Weapon
var direction: Vector2 = Vector2.ZERO
var attacker: Node = null

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body):
	if body == attacker:
		return
	
	#this is an ad hoc fix for now. when the enemy dies, 
	#the projectile still exists but its stored references (ie, attacker) become invalid
	#as it points to freed nodes
	if !is_instance_valid(attacker) or !is_instance_valid(weapon):
		queue_free()
		return
		
	if body in weapon.get_targets(attacker):
		var final_damage = weapon.calculate_damage(attacker)
		body.take_damage(final_damage)
	queue_free()
