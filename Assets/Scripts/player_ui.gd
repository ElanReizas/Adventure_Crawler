extends CanvasLayer

@export var health_bar: TextureProgressBar
@export var coin_label: Label
@export var health_label: Label
@export var potion_label: Label
func _process(_delta):
	if GameManager.player:
		var p = GameManager.player
		health_bar.max_value = p.max_health
		health_bar.value = p.current_health
		coin_label.text = str(p.gold)
		health_label.text = str(p.current_health) + "/" + str(p.max_health)
		potion_label.text = "x" + str(p.potions)
