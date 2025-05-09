extends Node

@onready var menu = $Menu
@onready var world = $World
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var anim_player = $CanvasLayer/PauseMenu/AnimationPlayer
@onready var input_manager = $InputLayer/InputManager

#const Player = preload("res://scenes/player.tscn")

var esc_input_cooldown := 0

func _process(_delta):
	if esc_input_cooldown > 0:
		esc_input_cooldown -= 1

func _ready():
	menu.show()
	world.hide()
	Global.menu = menu
	Global.world = world
	menu.start_game_pressed.connect(_on_start_game_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.quit_to_menu_requested.connect(_on_quit_to_menu)

func start_game():
	
	print("Player configs:", Global.player_configs)

	for p in Global.player_configs:
		if p != null:
			world.show()
			await get_tree().process_frame  # Let world _ready() run
			world.spawn_players()  # Manually call it here
			menu.hide()
			print("PLAYER SPAWN")
			Global.is_gameplay = true
			return
	print("No valid players, game not started")

func _on_start_game_pressed():
	start_game()


func _on_resume_requested():
	get_tree().paused = false
	anim_player.play_backwards("blur")
	

func _on_quit_to_menu():
	anim_player.play_backwards("blur")
	get_tree().paused = false
	world.hide()
	menu.show()
	menu.clear_player_slots()
	for player in Global.players:	
		player.queue_free()
	Global.reset()
	world.trail_image.fill(Color.BLACK)
	world.trail_texture.update(world.trail_image)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and world.visible:
		if get_tree().paused:
			_on_resume_requested()
		else:
			anim_player.play("blur")
			pause_menu.show()
			get_tree().paused = true
