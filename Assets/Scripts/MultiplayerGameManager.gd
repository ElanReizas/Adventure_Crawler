extends Node

@export var host_game: Button
@export var join_as_player_2: Button

# This script and the node it is attached to (GameManager) will have to be refactored after making multiplayer a choice once on start
# This was a prototype to get multiplayer itself going

func _ready():
	host_game.pressed.connect(become_host)
	join_as_player_2.pressed.connect(_join_as_player_2)
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		MultiplayerManager.become_host()

func become_host():
	print("Become host pressed")
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func _join_as_player_2():
	print("Join as player 2")
	%MultiplayerHUD.hide()
	MultiplayerManager.join_as_player_2()
