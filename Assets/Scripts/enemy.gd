extends CharacterBody2D
class_name Enemy
@onready var target = null
var player_in_sight: bool = false
@export var speed: float = 100.0
var max_health: int = 100
@export var current_health: int
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

@onready var current_distance
var knockback_cooldown: float = 0.0
var knockback_interval: float = 0.4

@export var drop_chance: float = 1.0   # % chance to drop an item
@export var possible_drops: Array[Item] = []
@export var drop_radius: float = 60.0

@export var detection_radius: float = 250.0
@export var attack_radius: float = 150.0
@export var max_pursuit_time: float = 10.0

#PATROL STATES

enum EnemyState { PATROL, PURSUIT, RETURN }

var state: EnemyState = EnemyState.PATROL
var pursuit_timer: float = 0.0
var patrol_target: Vector2 = Vector2.ZERO

@export var patrol_idle_time: float = 1.0  # seconds to idle at each patrol point
var patrol_idle_timer: float = 0.0
var is_idling: bool = false

@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"

@onready var enemy_id: String = ""

func _ready():
	
	#randomize for patroling
	randomize()
	enemy_id = get_path()
	if GameManager.is_enemy_dead(enemy_id):
		print("i died already:", enemy_id)
		queue_free()
		return
	add_to_group("enemies")
	
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	#if theres a player, grab the first one
	#will add proximity prioritization after multipler is implemented
	if players.size()>0:
		target =players[0]
		
	equip_weapon(WEAPON_PATHS[weapon_type])
	#ranged enemies use detection radius as attack radius
	update_ranged_attack_radius()
	#wait for navmesh to sync before patrol
	call_deferred("_init_patrol")

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
func _physics_process(delta: float) -> void:
	
	#just for debugging
	queue_redraw()
	knockback_cooldown = max(knockback_cooldown - delta, 0)
	acquire_target()
	
	#transition to pursuit if detected
	if can_detect_player() and state != EnemyState.PURSUIT:
		state = EnemyState.PURSUIT
		pursuit_timer = 0.0

	#run the active state behavior
	match state:
		EnemyState.PATROL:
			patrol_behavior()
		EnemyState.PURSUIT:
			pursuit_behavior(delta)
		EnemyState.RETURN:
			return_behavior()
			
	var collision := move_and_collide(velocity * delta)
	if collision and knockback_cooldown == 0:
		var collided_body: Node = collision.get_collider()
		if collided_body == target:
			var direction: Vector2 = (target.global_position - global_position).normalized()
			target.apply_knockback(direction, 300)
			target.take_damage(4)
			knockback_cooldown = knockback_interval




func acquire_target() -> bool:
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
	
	return true

func can_detect_player() -> bool:
	
	if target == null:
		return false

	# Must be inside detection radius
	if global_position.distance_to(target.global_position) > detection_radius:
		return false
	# gwt navmap
	var nav_map := nav.get_navigation_map()
	if nav_map == RID():
		return false
	
	# prevents navigation query before syncing
	if NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		return false
	
	# Check if player is inside patrol region
	var player_nav_point := NavigationServer2D.map_get_closest_point(nav_map, target.global_position)

	if player_nav_point.distance_to(target.global_position) > 16:
		return false

	# LOS check
	SightCheck()
	return player_in_sight

#PATROL + PURSUIT + RETURN BEHAVIOR

func patrol_behavior():
	
	# idle at patrol points for a bit
	if is_idling:
		patrol_idle_timer -= get_physics_process_delta_time()
		velocity = Vector2.ZERO

		if patrol_idle_timer <= 0.0:
			is_idling = false
			patrol_target = get_random_patrol_point()
			nav.set_target_position(patrol_target)
		return

	# Normal patrol movement
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed

	# idle when reaching patrol point
	if global_position.distance_to(patrol_target) < 20:
		is_idling = true
		patrol_idle_timer = patrol_idle_time
		velocity = Vector2.ZERO


func pursuit_behavior(delta: float):
	
	#never idle when chasing
	is_idling = false
	
	#return to patroling if target is lost
	if target == null:
		state = EnemyState.RETURN
		velocity = Vector2.ZERO
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)
		return

	# validate navmesh
	var nav_map := nav.get_navigation_map()
	
	if nav_map == RID():
		return
		
	if NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		return
		
	var player_nav_point := NavigationServer2D.map_get_closest_point(nav_map, target.global_position)

	# confirm player is still inside patrol region
	if player_nav_point.distance_to(target.global_position) > 16:
		state = EnemyState.RETURN
		velocity = Vector2.ZERO
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)
		return

	# update chase timer and distance
	pursuit_timer += delta
	current_distance = global_position.distance_to(target.global_position)
	
	# Update nav target ONLY when we actually want to move closer
	if equipped_weapon is MeleeWeapon:
		nav.set_target_position(target.global_position)
	elif equipped_weapon is RangedWeapon:
		if current_distance > follow_distance_max or not player_in_sight:
			nav.set_target_position(target.global_position)

	# Ranged attack: require both range AND clear projectile path
	if equipped_weapon is RangedWeapon and current_distance <= attack_radius:
		# Direction the projectile will travel
		var aim_direction : Vector2 = (target.global_position - global_position).normalized()
		
		# Simulate projectile spawn position (same offset used in RangedWeapon)
		var spawn_pos: Vector2 = global_position + aim_direction * 20.0
		
		# Raycast from projectile spawn → player to ensure shot is not blocked by walls/corners
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.new()
		query.from = spawn_pos
		query.to = target.global_position
		query.exclude = [self]
		
		var result := space_state.intersect_ray(query)

		# Only fire if the projectile path actually hits the player
		if not result.is_empty() and result.collider == target:
			equipped_weapon.attack(self, aim_direction)
		else:
			# Path is blocked: move to reposition instead of shooting the wall
			nav.set_target_position(target.global_position)

		#THIS IS A BUG RN
	#elif equipped_weapon:
		#if current_distance <= attack_radius:
			#var aim_direction = (target.global_position - global_position).normalized()
			#equipped_weapon.attack(self, aim_direction)



	# Movement based on weapon type
	if equipped_weapon is MeleeWeapon:
		meleeMovement()
	elif equipped_weapon is RangedWeapon:
		SightCheck()
		rangedMovement()

	# Give up after max pursuit time
	if pursuit_timer > max_pursuit_time:
		state = EnemyState.RETURN
		velocity = Vector2.ZERO
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)


func return_behavior():
	var dir = to_local(nav.get_next_path_position()).normalized()
	velocity = dir * speed

	if global_position.distance_to(patrol_target) < 20:
		is_idling = false
		state = EnemyState.PATROL
		patrol_target = get_random_patrol_point()
		nav.set_target_position(patrol_target)
	# gwt navmap
	var nav_map := nav.get_navigation_map()
	if nav_map == RID():
		return false
	
	# prevents navigation query before syncing
	if NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		return false
	
	# Check if player is inside patrol region
	var player_nav_point := NavigationServer2D.map_get_closest_point(nav_map, target.global_position)

	if player_nav_point.distance_to(target.global_position) > 16:
		return false

	# LOS check
	SightCheck()
	return player_in_sight

func update_ranged_attack_radius():
	
	if weapon_type == WeaponType.RANGED:
		attack_radius = detection_radius

#NAVIGATION

func get_random_patrol_point() -> Vector2:
	
	#get navigation map
	var nav_map := nav.get_navigation_map()
	
	# if map is invalid fallback to staying in place
	if nav_map == RID():
		return global_position

	#get random point using built in function
	var point := NavigationServer2D.map_get_random_point(
		nav_map,
		nav.navigation_layers,
		true
	)

	#safety check in case the navigation server returns an invalid value
	if not point.is_finite():
		return global_position

	#snap point to closest valid position in the navmesh
	return NavigationServer2D.map_get_closest_point(nav_map, point)


func _init_patrol():
	
	#get navigation map
	var nav_map := nav.get_navigation_map()
	
	#if the navigation map is not ready wait a frame and try again
	if nav_map == RID():
		await get_tree().process_frame
		nav_map = nav.get_navigation_map()
		
		# if still invalid after waiting abort the initialization
		if nav_map == RID():
			return  # give up quietly, avoids errors

	# Wait until the navigation map is fully synchronized
	while NavigationServer2D.map_get_iteration_id(nav_map) == 0:
		await get_tree().process_frame

	# generate the first patrol target and assign it to the navigation agent
	patrol_target = get_random_patrol_point()
	nav.set_target_position(patrol_target)


func die():
	GameManager.mark_enemy_dead(enemy_id)
	drop_loot()
	
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])
	queue_free()


func drop_loot():
	# If no items assigned, nothing can drop
	if possible_drops.is_empty():
		return

	# Roll random chance
	if randf() > drop_chance:
		return

	# Pick random item from this enemy's drop table
	var item: Item = possible_drops.pick_random()

	# Spawn the item drop
	var drop_scene := preload("res://Assets/Scenes/ItemDrop.tscn")
	var drop := drop_scene.instantiate()

	drop.item = item

	# Spread items around the enemy using radius
	var offset := Vector2(
		randf_range(-drop_radius, drop_radius),
		randf_range(-drop_radius, drop_radius)
	)

	drop.global_position = global_position + offset
	get_tree().get_current_scene().call_deferred("add_child", drop)



func SightCheck():
	
	if target ==null:
		player_in_sight = false
		return
	
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
	
	# If we DO NOT have LOS, we must path toward the player to regain LOS
	if not player_in_sight:
		var nav_dir = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_dir * speed
		return

	#using a safe distance we can tell the agent whether its good to continue moving or not
	if (current_distance > follow_distance_max || not player_in_sight):
		#close in on player
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
	elif (current_distance<follow_distance_min):
			#player too close, move away from player
			var away_direction = (global_position - target.global_position).normalized()
			var proposed_pos = global_position + away_direction * 16

			var nav_map := nav.get_navigation_map()
			if nav_map != RID():
				var nav_pos := NavigationServer2D.map_get_closest_point(nav_map, proposed_pos)

				# Only back up if we stay inside the navmesh
				if nav_pos.distance_to(proposed_pos) <= 16:
					velocity = away_direction*speed
				else:
					velocity = Vector2.ZERO  # blocked by nav boundary
			else:
				velocity = Vector2.ZERO
	elif (follow_distance_min < current_distance && current_distance < follow_distance_max):
		#Comfort zone, we don't need to move anywhere
		velocity = Vector2.ZERO


#DEBUGGING

func _draw():
	var state_color := Color(0, 1, 0, 0.35) # green = patroling

	if state == EnemyState.PURSUIT:
		state_color = Color(1, 0, 0, 0.35) # red = chasing
	elif state == EnemyState.RETURN:
		state_color = Color(0, 0.5, 1, 0.35) # blue = returning

	# Detection radius (state-colored)
	draw_circle(Vector2.ZERO, detection_radius, state_color)

	# Attack radius (always white)
	draw_circle(Vector2.ZERO, attack_radius, Color(1, 1, 1, 0.25))

	# Patrol destination marker
	if state != EnemyState.PURSUIT:
		draw_circle(to_local(patrol_target), 6, Color(1, 1, 0, 0.9))
