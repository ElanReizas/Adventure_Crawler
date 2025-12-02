extends CharacterBody2D
@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D
@onready var health_bar = $UI/ProgressBar
var direction : Vector2
var max_health: int  = 200
var current_health: int = max_health
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	if current_health <= 0:
		health_bar.visible = false
		find_child("FiniteStateMachine").change_state("Death")
	
func _ready():
	health_bar.max_value = max_health
	health_bar.value = max_health
	set_physics_process(false)
	#hard coding the slash animation to the empty one
	$Pivot/slash.frame = 7

func _process(_delta):
	#add to enemy group so they can recieve damage by player weapons
	add_to_group("enemies")
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
	
