extends CharacterBody2D
class_name Enemy
@onready var target = null
var player_in_sight: bool = false
@export var speed: float = 100.0
var max_health: int = 100
var current_health: int
#grab group of player in players
@onready var players = get_tree().get_nodes_in_group("player")
#Variable to determine if the player was seen by an enemy to initiate engage targetting
var playerSeen = false
#Enemy combat style
enum WeaponType { MELEE, RANGED }
@export var weapon_type: WeaponType = WeaponType.MELEE
var equipped_weapon: Weapon
const WEAPON_PATHS := {
	WeaponType.MELEE:  "res://Assets/Scenes/MeleeWeapon.tscn",
	WeaponType.RANGED: "res://Assets/Scenes/RangedWeapon.tscn"
}
@export var follow_distance_min:= 100 #how far to stay away from player
@export var follow_distance_max:= 700
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer
@onready var current_distance
func _ready():
	add_to_group("enemies")
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
	equip_weapon(WEAPON_PATHS[weapon_type])


func equip_weapon(path: String) -> void:
	var scene: PackedScene = load(path)
	var weapon_instance: Weapon = scene.instantiate()
	add_child(weapon_instance)
	equipped_weapon = weapon_instance

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()
func _physics_process(_delta: float) -> void:
	if (acquire_target()):
		current_distance = global_position.distance_to(target.global_position)
		if (equipped_weapon is MeleeWeapon):
			meleeMovement()
			#Establishes a path to the goal that the enemy will follow
		elif (equipped_weapon is RangedWeapon):
			SightCheck()
			rangedMovement()
		equipped_weapon.attack(self)
	move_and_slide()
			
			


#This function adjust the path after a certain amount of time to stay updated on where the player is
func _on_timer_timeout() -> void:
	if nav.target_position != target.position && playerSeen:
		nav.set_target_position(target.position)
	timer.start()

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


func SightCheck():
	var space_state = get_world_2d().direct_space_state

	# Raycast setup: start at enemy, end at player
	var query := PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = target.global_position

	# Avoid colliding with the enemy itself
	query.exclude = [self]

	# Perform the raycast
	var result = space_state.intersect_ray(query)

	# If no collision was found, LOS is blocked or no objects in between
	if result.is_empty():
		player_in_sight = false
		return

	# TRUE only if the ray hits the player directly
	player_in_sight = (result.collider == target)
	
func meleeMovement():
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
	
func rangedMovement():
	#using a safe distance we can tell the agent whether its good to continue moving or not
	if (current_distance > follow_distance_max || not player_in_sight):
		#close in on player
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
	elif (current_distance<follow_distance_min):
			#player too close, move away from player
			var away_direction = (global_position - target.global_position).normalized()
			velocity = away_direction*speed
	elif (follow_distance_min < current_distance && current_distance < follow_distance_max):
		#Comfort zone, we don't need to move anywhere
		velocity = Vector2.ZERO
