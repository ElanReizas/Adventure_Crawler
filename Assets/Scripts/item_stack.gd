class_name ItemStack
extends Resource


# Called when the node enters the scene tree for the first time.
signal item_changed(item: Item)
static var max_count := 100
var _item: Item:
	set(val):
		_item = val
		item_changed.emit(val)
	get:
		return _item

var count: int = 0


func _init(item: Item, count: int = 0):
	_item = item
	self.count = count
