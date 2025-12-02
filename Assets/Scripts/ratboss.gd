extends CharacterBody2D
@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D

var direction : Vector2
func _ready():
	set_physics_process(false)
	#hard coding the slash animation to the empty one
	$Pivot/slash.frame = 7

func _process(_delta):
	#updating direction with player position
	direction = player.position - position
	#flipping direction towards player
	if direction.x <0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	velocity = direction.normalized()*40
	move_and_collide(velocity*delta)
	
