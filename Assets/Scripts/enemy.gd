extends Node2D
class_name Enemy

# ---------------------------------------------------
# HEALTH
# ---------------------------------------------------
var max_health: int = 100
var current_health: int
@onready var health_bar: ProgressBar = $HealthBar

# ---------------------------------------------------
# PATROL + AI
# ---------------------------------------------------

# ✔ Right half of a 1920×1080 room
#   Rect2(position_x, position_y, width, height)
@export var patrol_zone: Rect2 = Rect2(960, 0, 960, 1080)

@export var patrol_speed: float = 80
@export var chase_speed: float = 140
@export var chase_time_limit: float = 3.0
@export var detection_radius: float = 200.0

var patrol_target: Vector2
var state := "PATROL"   # PATROL, CHASE, RETURNING
var chase_timer: float = 0.0
var player_ref: Player = null


func _ready():
	# HEALTH init
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	# First patrol point
	patrol_target = _get_new_patrol_point()


func _physics_process(delta):
	_find_player()

	match state:
		"PATROL":
			_patrol_behavior(delta)
		"CHASE":
			_chase_behavior(delta)
		"RETURNING":
			_return_to_patrol_behavior(delta)


# ---------------------------------------------------
# PATROL LOGIC (GLOBAL patrol zone)
# ---------------------------------------------------
func _patrol_behavior(delta):
	if global_position.distance_to(patrol_target) < 5:
		patrol_target = _get_new_patrol_point()

	var dir = (patrol_target - global_position).normalized()
	global_position += dir * patrol_speed * delta

	if player_ref and _player_in_detection_radius() and _player_in_patrol_zone():
		state = "CHASE"
		chase_timer = chase_time_limit


# ---------------------------------------------------
# GENERATE PATROL POINT INSIDE GLOBAL RECT2
# ---------------------------------------------------
func _get_new_patrol_point() -> Vector2:
	var x = randf_range(patrol_zone.position.x, patrol_zone.position.x + patrol_zone.size.x)
	var y = randf_range(patrol_zone.position.y, patrol_zone.position.y + patrol_zone.size.y)
	return Vector2(x, y)


# ---------------------------------------------------
# CHASE LOGIC
# ---------------------------------------------------
func _chase_behavior(delta):
	if not player_ref:
		state = "RETURNING"
		return

	chase_timer -= delta

	if chase_timer <= 0 or not _player_in_patrol_zone():
		state = "RETURNING"
		return

	var dir = (player_ref.global_position - global_position).normalized()
	global_position += dir * chase_speed * delta


# ---------------------------------------------------
# RETURN TO PATROL
# ---------------------------------------------------
func _return_to_patrol_behavior(delta):
	if global_position.distance_to(patrol_target) < 5:
		state = "PATROL"
		return

	var dir = (patrol_target - global_position).normalized()
	global_position += dir * patrol_speed * delta


# ---------------------------------------------------
# HELPERS
# ---------------------------------------------------
func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]


func _player_in_detection_radius() -> bool:
	return global_position.distance_to(player_ref.global_position) <= detection_radius


func _player_in_patrol_zone() -> bool:
	return patrol_zone.has_point(player_ref.global_position)


# ---------------------------------------------------
# DAMAGE + DEATH
# ---------------------------------------------------
func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()

func die():
	queue_free()


# ---------------------------------------------------
# DEBUG DRAW (GLOBAL)
# ---------------------------------------------------
func _draw():
	# Draw patrol zone exactly as global rect
	draw_rect(patrol_zone, Color(0,1,0,0.2), true)
	draw_rect(patrol_zone, Color.GREEN, false)

	# Detection radius (local)
	draw_circle(Vector2.ZERO, detection_radius, Color(1,0,0,0.2))
	draw_circle(Vector2.ZERO, detection_radius, Color.RED)


func _process(delta):
	queue_redraw()
