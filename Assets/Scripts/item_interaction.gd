extends Node2D
var shop_inventory: Array[ItemStack]= []
@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "itemHolder"
@export var item_price: int = 10
@export var items: Array[Item]
@onready var sprite_node := $Sprite2D
@onready var textBox := $Label
@onready var player = $"../../Player"
@export var current_item: Item = null

var SAVE_PATH := "user://userData/save.json"
const RARITY_WEIGHTS: Dictionary[String, int] = {
	"Common": 60,
	"Uncommon": 25,
	"Rare": 10,
	"Epic": 5
}


func _ready():
	load_shop_state()
	generate_shop(shop_inventory.size())

	current_item = pick_random_item()
	#Change sprite into selected item
	if current_item:
		sprite_node.texture = current_item.sprite
	#Set Price
	if current_item.rarity == "Common":
		textBox.set_text("10 gold")
		item_price = 10
	elif current_item.rarity == "Uncommon":
		textBox.set_text("15 gold")
		item_price = 15
	elif current_item.rarity == "Epic":
		textBox.set_text("20 gold")
		item_price = 20
	
func interaction():
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])

func buy_item(player, slot_index: int):
	var slot = shop_inventory[slot_index]

	if slot == null:
		return # already empty

	# Handle currency checks here
	# player_gold -= slot.item.cost

	shop_inventory[slot_index] = null  # permanently empty
	save_shop_state()


	# Check gold
	if player.coins < item_price:
		return # Not enough money

	# Remove the coins
	player.coins -= item_price

	# Add the item to player’s inventory (you will implement add_item)
	#player.inventory.add_item(current_item)

#weighted random selection of an item
func pick_random_item() -> Item:
	var pool: Array = []

	for item in items:
		var weight: int = RARITY_WEIGHTS.get(item.rarity, 0)
		if weight > 0:
			pool.resize(pool.size() + weight)
			for i in range(weight):
				pool[pool.size() - i - 1] = item

	if pool.is_empty():
		return null

	return pool.pick_random()
#persistant shop generation
#selected a random weighted item
func generate_shop(num_items: int = 3):
	# If the shop already exists, DO NOT regenerate
	if shop_inventory.size() > 0:
		return

	for i in range(num_items):
		var item := pick_random_item()
		if item:
			shop_inventory.append(ItemStack.new(item, 1))
		else:
			shop_inventory.append(null) # empty slot
#persistance support
#Save the current shop
func save_shop_state():
	var data = []
	for slot in shop_inventory:
		if slot == null:
			data.append(null)
		else:
			data.append(slot.item.id) # save item ID only

	FileAccess.open(SAVE_PATH, FileAccess.WRITE).store_var(data)
#load shop
func load_shop_state():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var data = FileAccess.open(SAVE_PATH, FileAccess.READ).get_var()

	shop_inventory.clear()
	for id in data:
		if id == null:
			shop_inventory.append(null)
		else:
			var item = find_item_by_id(id)
			shop_inventory.append(ItemStack.new(item, 1))
#helper to find item list
func find_item_by_id(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null
	
func purchase_item(Item):
	if player.gold < item_price:
		DialogueManager.show_dialogue_balloon(load("res://Assets/DialogueFiles/testing.dialogue"), "noMoney")
	else:
		DialogueManager.show_dialogue_balloon(load("res://Assets/DialogueFiles/testing.dialogue"), "yesMoney")
		player.inventory.attempt_pickup(player, current_item)
		player.gold -= item_price
		#delete the shop stand
		queue_free()
		
	
