extends CharacterBody2D
class_name Enemy


enum State { PATROL, PURSUIT, RETURN }
var state: State = State.PATROL
var pursuit_timer: float = 0.0
var patrol_target: Vector2 = Vector2.ZERO


@export var detection_radius: float = 250.0   # when enemy notices player
@export var attack_radius: float = 150.0      # when enemy can attack player
@export var max_pursuit_time: float = 10.0    # give up after X seconds

#Enemy walakable area
@export var nav_region: NavigationRegion2D    # assign in the insepctor editor


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
	randomize()
	add_to_group("enemies")

	timer.timeout.connect(_on_timer_timeout)

	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	#if theres a player, grab the first one
	#will add proximity prioritization after multipler is implemented
	if players.size() > 0:
		target = players[0]
	else:
		playerSeen = false

	equip_weapon(WEAPON_PATHS[weapon_type])

	# Initial patrol target from navmesh
	patrol_target = get_random_patrol_point()
	nav.set_target_position(patrol_target)

	timer.start()



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

func die():
	queue_free()



func _physics_process(delta: float) -> void:
	acquire_target()
	queue_redraw()  # draws debug radii

	if can_detect_player() and state != State.PURSUIT:
		state = State.PURSUIT
		pursuit_timer = 0.0

	#Enemy now is set to 3 differnet states
	match state:
		State.PATROL:
			patrol_behavior()
		State.PURSUIT:
			pursuit_behavior(delta)
		State.RETURN:
			return_behavior()

	move_and_slide()



func _on_timer_timeout() -> void:
	if state == State.PURSUIT and target:
		nav.set_target_position(target.global_position)
	timer.start()



func acquire_target() -> bool:
	players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		return true
	target = null
	return false


func targetPlayer():
	playerSeen = true



func can_detect_player() -> bool:
	if target == null:
		return false

	# detection radius: circle around enemy
	return global_position.distance_to(target.global_position) <= detection_radius



func patrol_behavior():
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed

	if global_position.distance_to(patrol_target) < 20:
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)



func pursuit_behavior(delta: float):
	if target == null:
		state = State.RETURN
		return

	pursuit_timer += delta
	current_distance = global_position.distance_to(target.global_position)

	nav.set_target_position(target.global_position)

	# Only attack if inside attack radius
	if global_position.distance_to(target.global_position) <= attack_radius:
		equipped_weapon.attack(self)

	if equipped_weapon is MeleeWeapon:
		meleeMovement()
	elif equipped_weapon is RangedWeapon:
		SightCheck()
		rangedMovement()

	if pursuit_timer > max_pursuit_time:
		state = State.RETURN
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)



func return_behavior():
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed

	if global_position.distance_to(patrol_target) < 20:
		state = State.PATROL
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)



func get_random_patrol_point() -> Vector2:
	if nav_region == null or nav_region.navigation_polygon == null:
		return global_position

	var navpoly: NavigationPolygon = nav_region.navigation_polygon
	var polys := navpoly.polygons
	if polys.is_empty():
		return global_position

	var poly = polys[randi() % polys.size()]
	if poly.size() < 3:
		return nav_region.global_position

	var verts: PackedVector2Array = navpoly.vertices

	var a = verts[poly[0]]
	var b = verts[poly[1]]
	var c = verts[poly[2]]

	var r1 = randf()
	var r2 = randf()
	var sqrt_r1 = sqrt(r1)

	var local = a * (1.0 - sqrt_r1) \
		+ b * (sqrt_r1 * (1.0 - r2)) \
		+ c * (sqrt_r1 * r2)

	return nav_region.to_global(local)



func SightCheck():
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = target.global_position
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	player_in_sight = not result.is_empty() and result.collider == target


func meleeMovement():
	var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
	velocity = nav_point_direction * speed


func rangedMovement():
	if (current_distance > follow_distance_max or not player_in_sight):
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
	elif (current_distance < follow_distance_min):
		var away_direction = (global_position - target.global_position).normalized()
		velocity = away_direction * speed
	else:
		velocity = Vector2.ZERO



func _draw():
	var color = Color(1,1,0,0.25)  # patrol/detection circle
	if state == State.PURSUIT:
		color = Color(1,0,0,0.35)
	elif state == State.RETURN:
		color = Color(0,0.5,1,0.35)

	# detection radius
	draw_circle(Vector2.ZERO, detection_radius, color)

	# attack radius (white)
	draw_circle(Vector2.ZERO, attack_radius, Color(1,1,1,0.25))
