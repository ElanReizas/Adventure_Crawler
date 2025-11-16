extends CharacterBody2D
class_name Enemy

@onready var target = null
@export var speed: int = 200

var max_health: int = 100
var current_health: int

@export var attack_damage: int = 5
@export var attack_interval: float = 0.5  # how often enemy deals melee damage

@onready var players = get_tree().get_nodes_in_group("player")
var playerSeen: bool

@onready var health_bar: ProgressBar = $HealthBar
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var navigation_timer: Timer = $NavigationTimer     # UPDATED NAME
@onready var attack_cooldown: Timer = $AttackCooldown       # correct name
@onready var hitbox: Area2D = $Hitbox

var can_attack: bool = true
var player_in_hitbox: Player = null     # tracks if player is inside hitbox


func _ready():
	# connect timers
	navigation_timer.timeout.connect(_on_navigation_timer_timeout)
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)

	# connect hitbox enter + exit
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.body_exited.connect(_on_hitbox_body_exited)

	# init health
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	# target player
	if players.size() > 0:
		target = players[0]
		nav.set_target_position(target.position)


func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()


func _physics_process(_delta: float) -> void:
	targetPlayer()

	if playerSeen:
		var nav_point_direction = to_local(nav.get_next_path_position()).normalized()
		velocity = nav_point_direction * speed
		move_and_slide()


# ---------------------------------
# NAVIGATION UPDATE TIMER
# ---------------------------------
func _on_navigation_timer_timeout() -> void:
	if nav.target_position != target.position and playerSeen:
		nav.set_target_position(target.position)
	navigation_timer.start()


func targetPlayer():
	playerSeen = true


# ---------------------------------
# HITBOX DAMAGE SYSTEM
# ---------------------------------
func _on_hitbox_body_entered(body):
	if body is Player:
		player_in_hitbox = body
		if can_attack:
			_do_attack()


func _on_hitbox_body_exited(body):
	if body is Player:
		player_in_hitbox = null


func _do_attack():
	if player_in_hitbox and can_attack:
		player_in_hitbox.take_damage(attack_damage)
		can_attack = false
		attack_cooldown.start()


# ---------------------------------
# ATTACK COOLDOWN TIMER
# ---------------------------------
func _on_attack_cooldown_timeout():
	can_attack = true
	# If the player is still inside hitbox → attack again
	_do_attack()


func die():
	queue_free()
