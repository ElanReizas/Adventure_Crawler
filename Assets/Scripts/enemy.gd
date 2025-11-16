extends CharacterBody2D
class_name Enemy
@onready var target = null
@export var speed: float = 200.0
var max_health: int = 100
var current_health: int
#grab group of player in players
@onready var players = get_tree().get_nodes_in_group("player")
#Variable to determine if the player was seen by an enemy to initiate engage targetting
var playerSeen = false
#Enemy combat style
@export var equipped_weapon: Weapon
@export var follow_distance_min:= 550 #how far to stay away from player
@export var follow_distance_max:= 700
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer
@onready var current_distance
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
	else:
		playerSeen = false
		#$NavigationAgent2D.set_target_position(target.position)
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()
func _physics_process(_delta: float) -> void:
	if (acquire_target()):
		current_distance = global_position.distance_to(target.global_position)
		if not (equipped_weapon is RangedWeapon):
			#Establishes a path to the goal that the enemy will follow
			var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
			velocity = nav_point_direction * speed
		else:
			#using a safe distance we can tell the agent whether its good to continue moving or not
			if (current_distance > follow_distance_max):
				#close in on player
				var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
				velocity = nav_point_direction * speed
			else: if (current_distance<follow_distance_min):
					#player too close, move away from player
					var away_direction = (global_position - target.global_position).normalized()
					velocity = away_direction*speed
			if (follow_distance_min < current_distance && current_distance < follow_distance_max):
				velocity = Vector2.ZERO
	move_and_slide()
			#Comfort zone, we don't need to move anywhere
			


#This function adjust the path after a certain amount of time to stay updated on where the player is
func _on_timer_timeout() -> void:
	if nav.target_position != target.position && playerSeen:
		nav.set_target_position(target.position)
	timer.start()
#Targeting function
#initial testing we set playerSeen to true to skip past patrolling phase
#this is made for melee enemies
#LOS to be further implemented
func acquire_target() -> bool:
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		nav.set_target_position(target.position)
		return true
	else:
			target = null
			return false
			
func targetPlayer(): 
	playerSeen=true
	

func die():
	queue_free()
