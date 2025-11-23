class_name Items
extends Node2D

@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"
@export var itemPrice: int= 10 #Dependent on item rarity
@export var coins: int=0
@export var items: Array[Item]
func _onready():
	Sprite2D = Item.
	
func interaction():
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])

func purchase():
	#player has attempted to purchase item via dialogue
	#Check players gold amount
	#If enough, check two more conditions ->
		#If player has no stored slot for item, equip purchased item
		#otherwise drop currently held item, equip purchased item
	#subtract gold count
	pass
