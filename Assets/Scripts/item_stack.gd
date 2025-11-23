class_name ItemStack
extends Node2D


# Called when the node enters the scene tree for the first time.
signal item_changed(item: Item)
static var max_count := 100
var item: Item:
	set(val):
		item = val
		item_changed.emit(val)
var count : int

func _init(item: Item, count: int = 0):
	self.item = item
	self.count = count

#func is_empty() -> bool:
	#return item == Items.Empty
	
#func _to_string() -> String:
#	return ItemStack
