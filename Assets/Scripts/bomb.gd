extends Area2D
class_name Bomb

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var speed: float = 600.0
@export var weapon: Weapon
@onready var explosion_hitbox: CollisionShape2D = $"explosion hitbox"

var direction: Vector2 = Vector2.ZERO
var attacker: Node = null
var exploded: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if exploded:
		return
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body):
	if exploded:
		return
	if body == attacker:
		return

	# Invalid references -> still explode
	if !is_instance_valid(attacker) or !is_instance_valid(weapon):
		explode()
		return

	# Valid target hit
	if body in weapon.get_targets(attacker):
		var final_damage = weapon.calculate_damage(attacker)
		body.take_damage(final_damage)

	explode()

func explode():
	exploded = true
	speed = 0
	animation_player.play("explosion")
	await animation_player.animation_finished
	direction = Vector2.ZERO
	explosion_hitbox.set_deferred("disabled", true)
	
	queue_free()
