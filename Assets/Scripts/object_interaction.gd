extends Node2D

@export var dialogue_file: DialogueResource
@export var dialogue_title: String = "start"
@export var itemPrice: int= 10 #Dependent on item rarity
@export var coins: int=0

#on ready
#grab item from game library, determine price of that item and populate item and armor stands
#ensure population occurs only once and doesn't repopulate items after purchase
func interaction():
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_title, [self])
