extends CharacterBody2D
#@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D
@onready var health_bar = $UI/ProgressBar
@onready var players = get_tree().get_nodes_in_group("player")
@onready var target = null
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var direction : Vector2
var max_health: int  = 2000
var current_health: int = max_health
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	if current_health <= 0:
		health_bar.visible = false
		find_child("FiniteStateMachine").change_state("Death")
	
func _ready():
	nearest_player()
	#add to enemy group so they can recieve damage by player weapons
	add_to_group("enemies")
	health_bar.max_value = max_health
	health_bar.value = max_health
	set_physics_process(false)
	#hard coding the slash animation to the empty one
	$Pivot/slash.frame = 7

func _process(_delta):
	nearest_player()
	nav.set_target_position(target.global_position)
	direction = target.position - position
	#Flipping to player direction
	if direction.x <0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	velocity = direction.normalized()*70
	move_and_collide(velocity*delta)
	
func nearest_player():
	players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		target = null
		return false
	var nearest_player = null
	var nearest_distance = INF
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_player = player
	target = nearest_player
	
