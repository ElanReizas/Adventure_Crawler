extends CanvasLayer

@export var health_bar: TextureProgressBar
@export var coin_label: Label

func _process(_delta):
	if GameManager.player:
		health_bar.max_value = GameManager.player.max_health
		health_bar.value = GameManager.player.current_health
		coin_label.text = str(GameManager.player.gold)
