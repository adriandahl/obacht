extends Control

@onready var name_label = $VBoxContainer/HBoxContainer/PlayerName
@onready var left_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/LeftKey
@onready var item_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/ItemKey
@onready var right_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/RightKey
@onready var head_sprite = $VBoxContainer/PlayerHead
@onready var backlight = $Backlight

func setup(config: Dictionary):
	# Set player name
	print(name_label)
	name_label.text = config["name"]
	
	# Set key labels
	left_key.text = OS.get_keycode_string(config["left"])
	item_key.text = OS.get_keycode_string(config["item"])
	right_key.text = OS.get_keycode_string(config["right"])
	
	# Set color highlights
	var player_color = config["color"]
	name_label.add_theme_color_override("font_color", player_color)
	left_key.add_theme_color_override("font_color", player_color)
	item_key.add_theme_color_override("font_color", player_color)
	right_key.add_theme_color_override("font_color", player_color)

	#head_sprite.modulate = player_color
	# TODO: update in case custom heads get added

	# Backlight setup (radial glow texture modulated)
	backlight.modulate = Color(player_color.r, player_color.g, player_color.b, 0.2)
