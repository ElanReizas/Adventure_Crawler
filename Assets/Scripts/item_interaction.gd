extends Node2D
var shop_inventory: Array[ItemStack]= []
@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"
@export var itemPrice: int = 10
@export var items: Array[Item]
@onready var sprite_node := $Sprite2D
@onready var current_item: Item = null
const RARITY_WEIGHTS:= {
	"Common": 60,
	"Uncommon": 25,
	"Epic": 15
}

func _ready():
	current_item = pick_random_item()
	if current_item:
		sprite_node.texture = current_item.sprite
func interaction():
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])

func purchase(player):
	if not current_item:
		return

	# Check gold
	if player.coins < itemPrice:
		return # Not enough money

	# Remove the coins
	player.coins -= itemPrice

	# Add the item to player’s inventory (you will implement add_item)
	player.inventory.add_item(current_item)

	# Optionally regenerate the shop item
	current_item = pick_random_item()
	sprite_node.texture = current_item.sprite

	
func pick_random_item() -> Item:
	var pool := []

	for item in items:
		if RARITY_WEIGHTS.has(item.rarity):
			var weight = RARITY_WEIGHTS[item.rarity]
			for i in range(weight):
				pool.append(item)

	if pool.is_empty():
		return null

	return pool[randi() % pool.size()]
func generate_shop(num_items: int = 3):
	shop_inventory.clear()
	for i in range(num_items):
		var item := pick_random_item()
		if item:
			shop_inventory.append(ItemStack.new(item, 1))
