extends Area2D
class_name Projectile

@export var speed: float = 800.0
@export var weapon: Weapon
var direction: Vector2 = Vector2.ZERO
var player: Node = null

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		var final_damage = weapon.calculate_damage(player)
		body.take_damage(final_damage)
	queue_free()
