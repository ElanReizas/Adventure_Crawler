extends CharacterBody2D
@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D
@onready var health_bar = $UI/ProgressBar
var direction : Vector2
const MAX_HEALTH  = 2000
#Change healthbar
var _current_health: int = MAX_HEALTH
var current_health:
	set(value):
		_current_health = value
		health_bar.value = value
		if value <= 0:
			health_bar.visible = false
			find_child("FiniteStateMachine").change_state("Death")
	get:
		return _current_health
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	
func _ready():
	set_physics_process(false)
	#hard coding the slash animation to the empty one
	$Pivot/slash.frame = 7

func _process(_delta):
	#updating direction with player position
	direction = player.position - position
	#Flipping to player direction
	if direction.x <0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	velocity = direction.normalized()*40
	move_and_collide(velocity*delta)
	
