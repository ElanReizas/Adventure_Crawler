extends State


func enter():
	super.enter()
	animation_player.play("bossdeath")
	await animation_player.animation_finished
	animation_player.play("RatKingDefeat")
