extends Area2D
class_name ItemDrop

signal picked_up(item: Item)

@export var item: Item

@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	# Display the correct sprite for this item
	if item and item.sprite:
		sprite.texture = item.sprite

	# Track when a player enters/exits range
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.last_item_in_range = self


func _on_body_exited(body):
	if body.is_in_group("player") and body.last_item_in_range == self:
		body.last_item_in_range = null


func pickup(player: BasePlayer) -> void:
	# Delegate the pickup logic to the player's inventory
	player.inventory.attempt_pickup(player, item)
	queue_free()
