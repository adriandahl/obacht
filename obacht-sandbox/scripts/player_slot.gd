extends Control

@onready var name_label = $VBoxContainer/HBoxContainer/PlayerName
@onready var left_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/LeftKey
@onready var item_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/ItemKey
@onready var right_key = $VBoxContainer/HBoxContainer/VBoxContainer/KeyDisplay/RightKey
@onready var head_sprite = $VBoxContainer/PlayerHead
@onready var backlight = $Backlight
@onready var trail_preview = $TrailPreview
var player_color = Color.WHITE

var gap_offset := 0.0
var trail_length = 0

func setup(config: Dictionary):
	# Set player name
	print(name_label)
	name_label.text = config["name"]
	
	# Set key labels
	left_key.text = OS.get_keycode_string(config["left"])
	item_key.text = OS.get_keycode_string(config["item"])
	right_key.text = OS.get_keycode_string(config["right"])
	
	# Set color highlights
	player_color = config["color"]
	name_label.add_theme_color_override("font_color", Color.WHITE)
	left_key.add_theme_color_override("font_color", Color.WHITE)
	item_key.add_theme_color_override("font_color", Color.WHITE)
	right_key.add_theme_color_override("font_color", Color.WHITE)

	#head_sprite.centered = true
	#head_sprite.position.x = 20

	# Backlight glow setup
	backlight.texture = preload("res://assets/player_glow.png")
	
	# stay centered while stretching
	backlight.scale = Vector2(3.0, 3.0)
	#head_sprite.centered = true
	backlight.modulate = Color(player_color.r, player_color.g, player_color.b, 0.2)

	var min_x = custom_minimum_size.x
	var min_y = custom_minimum_size.y
	print(min_x)
	head_sprite.position = Vector2(min_x / 2, min_y - 30)

func _draw():
	if trail_length  < 160:
		trail_length += 1
	var trail_radius = 4
	
	var origin = head_sprite.position + Vector2(-4, 12)
	var spacing = 1  # Distance between blocks
	var gap_spacing = 150
	var gap_width = 40
	#var time_offset = int(Time.get_ticks_msec() / 20)  # animation seed

	for i in range(trail_length):
		var offset = Vector2(-i * spacing, 0)  # move LEFT from origin
		var point_pos = origin + offset

		#if posmod(i - time_offset, gap_spacing) < gap_width:
		if posmod(i - gap_offset, gap_spacing) < gap_width:
			continue  # simulate gap

		var alpha = 1.0 - float(i) / trail_length
		var faded_color = player_color
		faded_color.a = alpha

		draw_rect(Rect2(point_pos - Vector2(trail_radius, trail_radius), Vector2(trail_radius * 2, trail_radius * 2)), faded_color)


func _process(delta):
	gap_offset += delta * 50.0
	queue_redraw()
