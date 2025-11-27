extends Area2D
class_name ItemDrop

signal picked_up(item: Item)

@export var item: Item	# The actual item this drop represents

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
		# Let the player know this item can be picked up
		body.last_item_in_range = self


func _on_body_exited(body):
	if body.is_in_group("player"):
		if body.last_item_in_range == self:
			body.last_item_in_range = null


func pickup(player: BasePlayer) -> void:
	# Ask the player to attempt to equip this item
	player.attempt_pickup_item(item)

	# Remove the drop from the world
	queue_free()
