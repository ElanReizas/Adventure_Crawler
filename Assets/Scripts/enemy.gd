extends CharacterBody2D
class_name Enemy
@onready var target = null
@export var speed = 200
var max_health: int = 100
var current_health: int
#grab group of player in players
@onready var players = get_tree().get_nodes_in_group("player")
#Variable to determine if the player was seen by an enemy to initiate engage targetting
var playerSeen: bool
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	#if theres a player, grab the first one
	#will add proximity prioritization after multipler is implemented
	if players.size()>0:
		target =players[0]
		nav.set_target_position(target.position)
		#$NavigationAgent2D.set_target_position(target.position)
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()
func _physics_process(_delta: float) -> void:
	targetPlayer()
	if playerSeen:
		#Establishes a path to the goal that the enemy will follow
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
		move_and_slide()
#This function adjust the path after a certain amount of time to stay updated on where the player is
func _on_timer_timeout() -> void:
	if nav.target_position != target.position && playerSeen:
		nav.set_target_position(target.position)
	timer.start()
#Targeting function
#initial testing we set playerSeen to true to skip past patrolling phase
#this is made for melee enemies
#LOS to be further implemented
func targetPlayer(): 
	playerSeen=true
	

func die():
	queue_free()
