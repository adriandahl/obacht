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
			$World/GameUI.refresh_labels()
			menu.hide()
			print("PLAYER SPAWN")
			Global.is_gameplay = true
			return
	print("No valid players, game not started")

func _on_start_game_pressed():
	$World/GameUI.clear_scoreboard_ui()
	$World/GameUI.build_label_map()
	$World/GameUI.refresh_labels()
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
	
		# Draw yellow playfield border (2px thick)
	var size = get_viewport().get_visible_rect().size
	var image_size = Vector2i(size.x, size.y)
	var border_color = Color.YELLOW
	var thickness = 4
	var margin = 200

	for x in range(image_size.y):
		for t in range(thickness):
			world.trail_image.set_pixel(x + margin, t, border_color)  # Top
			world.trail_image.set_pixel(x + margin, image_size.y - 1 - t, border_color)  # Bottom

	for y in range(image_size.y):
		for t in range(thickness):
			world.trail_image.set_pixel(t + margin, y, border_color)  # Left
			world.trail_image.set_pixel(image_size.y - 1 - t + margin, y, border_color)  # Right
	
	world.trail_texture.update(world.trail_image)

func _unhandled_input(event):
	if event.is_action_pressed("load_debug_players"):
		load_debug_players()
		print("Debug players loaded.")
	if event.is_action_pressed("ui_cancel"):
		if world.visible:
			if get_tree().paused:
				_on_resume_requested()
			else:
				anim_player.play("blur")
				pause_menu.show()
				get_tree().paused = true
		else:
			# TODO: handle exit game
			return

func load_debug_players():
	var keys = [
		{ "left": KEY_A, "item": KEY_S, "right": KEY_D },
		{ "left": KEY_F, "item": KEY_G, "right": KEY_H },
		{ "left": KEY_J, "item": KEY_K, "right": KEY_L },
		{ "left": KEY_Q, "item": KEY_W, "right": KEY_E },
		{ "left": KEY_U, "item": KEY_I, "right": KEY_O },
		{ "left": KEY_Z, "item": KEY_X, "right": KEY_C },
		{ "left": KEY_V, "item": KEY_B, "right": KEY_N },
		{ "left": KEY_LEFT, "item": KEY_DOWN, "right": KEY_RIGHT },
	]

	var colors = Global.player_colors

	Global.player_configs.clear()
	for i in range(8):
		Global.player_configs.append({
			"name": "Player_%d" % i,
			"left": keys[i]["left"],
			"item": keys[i]["item"],
			"right": keys[i]["right"],
			"color": colors[i],
			"gap_chance": 0.1
		})
		
		# Update UI
		var menu = get_tree().root.get_node("Root/Menu")
		if menu:
			menu.show_player_slot_overlay(i)
