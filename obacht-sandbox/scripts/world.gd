extends Node2D

func _ready():
	print("Gameplay ready!")
	for p in Global.player_configs:
		print(str(p))
