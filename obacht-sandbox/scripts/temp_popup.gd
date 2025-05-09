# TODO: rename to setup_popup

extends Window

@onready var name_field = $MarginContainer/VBoxContainer/NameEdit
@onready var color_grid = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/ColorGrid
@onready var left_key_button = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/MarginContainer/KeyGrid/LeftKeyButton
@onready var right_key_button = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/MarginContainer/KeyGrid/RightKeyButton
@onready var item_key_button = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/MarginContainer/KeyGrid/ItemKeyButton
#@onready var confirm_button = $VBoxContainer/ButtonGrid/ConfirmButton
#@onready var cancel_button = $VBoxContainer/ButtonGrid/CancelButton

@onready var key_hint = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/KeyHint

var lock_icon = preload("res://assets/lock.png")

var player_index: int = Global.current_slot_index
var awaiting_key: String = ""
var temp_config: Dictionary = {}

func _ready():
	hide()
	# You can add default color samples dynamically if you want
	#fill_color_grid()

func highlight_selected_color(selected_index: int):
	var color_buttons = color_grid.get_children()

	for i in range(color_buttons.size()):
		var button = color_buttons[i]
		var style = StyleBoxFlat.new()

		# Set the button background color
		style.bg_color = Global.player_colors[i]

		# Border handling
		if i == selected_index:
			style.border_color = Color.WHITE
			style.set_border_width(SIDE_TOP, 4)
			style.set_border_width(SIDE_BOTTOM, 4)
			style.set_border_width(SIDE_LEFT, 4)
			style.set_border_width(SIDE_RIGHT, 4)
		else:
			style.border_color = Color.TRANSPARENT
			style.set_border_width(SIDE_TOP, 0)
			style.set_border_width(SIDE_BOTTOM, 0)
			style.set_border_width(SIDE_LEFT, 0)
			style.set_border_width(SIDE_RIGHT, 0)

		# Disable hover effect
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)

		# Apply the style
		button.add_theme_stylebox_override("normal", style)

func refresh_color_buttons(selected_index: int = -1):
	var color_buttons = color_grid.get_children()

	for i in range(color_buttons.size()):
		var button = color_buttons[i]
		var style = StyleBoxFlat.new()
		
		style.bg_color = Global.player_colors[i]

		# Check if this color is used by another player
		var color_taken = false

		for j in range(Global.player_configs.size()):
			if j == Global.current_slot_index:
				continue  # Ignore current player editing themselves

			var config = Global.player_configs[j]
			if config != null and config.get("color") == Global.player_colors[i]:
				color_taken = true
				break

		# If color is taken, gray it out and disable
		if color_taken:
			#button.disabled = true
			#style.bg_color = style.bg_color.darkened(0.5)  # Make it visibly grayed
			#style.border_color = Color.TRANSPARENT
			
			button.disabled = true
			style.bg_color = desaturate_color(style.bg_color, 0.5)
			
			if not button.has_node("LockIcon"):
				var lock_sprite = TextureRect.new()
				lock_sprite.name = "LockIcon"
				lock_sprite.texture = lock_icon
				lock_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				lock_sprite.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
				lock_sprite.anchor_left = 0.5
				lock_sprite.anchor_top = 0.5
				lock_sprite.anchor_right = 0.5
				lock_sprite.anchor_bottom = 0.5
				lock_sprite.modulate = Color(1, 1, 1, 0.7)
				lock_sprite.scale = Vector2(0.07, 0.07)

				button.add_child(lock_sprite)
		else:
			button.disabled = false
			# if lock still exists, remove it
			if button.has_node("LockIcon"):
				button.get_node("LockIcon").queue_free()

			# selection highlight
			if i == selected_index:
				style.border_color = Color.WHITE
				style.set_border_width_all(4)
			else:
				style.border_color = Color.TRANSPARENT
				style.set_border_width_all(0)
		
		# apply styles to all states
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)

func desaturate_color(color: Color, amount: float) -> Color:
	var grayscale = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
	var gray_color = Color(grayscale, grayscale, grayscale)
	return color.lerp(gray_color, amount)

func _on_color_button_pressed(index):
	if index >= 0 and index < Global.player_colors.size():
		temp_config["color"] = Global.player_colors[index]
		highlight_selected_color(index)

func _on_key_button_pressed(key):
	# 0 = left
	# 1 = item
	# 2 = right
	key_hint.show()
	match key:
		0:
			awaiting_key = "left"
			
		1:
			awaiting_key = "item"
			
		2:
			awaiting_key = "right"

func open_with_config():
	print(Global.player_configs)
	var config = Global.player_configs[Global.current_slot_index]
	if config != null:
		temp_config = config.duplicate()
		temp_config["color"]=config["color"]
	else:
		temp_config = {
			"name": "",
			"color": Color.WHITE,
			"left": null,
			"right": null,
			"item": null
		}
		name_field.text = ""
		left_key_button.text = ""
		right_key_button.text = ""
		item_key_button.text = ""
		
		refresh_color_buttons()
		popup_centered()
		return
	
	name_field.text = temp_config["name"]
	left_key_button.text = OS.get_keycode_string(temp_config["left"])
	item_key_button.text = OS.get_keycode_string(temp_config["item"])
	right_key_button.text = OS.get_keycode_string(temp_config["right"])
	
		# find selected color index
	var selected_color_index = -1
	for i in range(Global.player_colors.size()):
		if Global.player_colors[i] == temp_config["color"]:
			selected_color_index = i
			break

	refresh_color_buttons(selected_color_index)
	
	#refresh_color_buttons()
	popup_centered()

func _input(event):
	#print(event)
	if event is InputEventKey and event.pressed and awaiting_key != "":
		var keycode = event.keycode
		var key_name = OS.get_keycode_string(keycode)

		match awaiting_key:
			"left":
				temp_config["left"] = keycode
				left_key_button.text = key_name
				# Cycle through keys
				if temp_config.get("item", null) == null:
					awaiting_key = "item"
					item_key_button.grab_focus()
					return
			"item":
				temp_config["item"] = keycode
				item_key_button.text = key_name
				if temp_config.get("right", null) == null:
					awaiting_key = "right"
					right_key_button.grab_focus()
					return
			"right":
				temp_config["right"] = keycode
				right_key_button.text = key_name
				if temp_config.get("left", null) == null:
					awaiting_key = "left"
					left_key_button.grab_focus()
					return

		awaiting_key = ""
		key_hint.hide()

func _on_confirm_button_pressed():
	temp_config["name"] = name_field.text
	if temp_config["name"] == "" \
	or temp_config["color"] == Color.WHITE \
	or temp_config["left"] == null \
	or temp_config["item"] == null \
	or temp_config["right"] == null:
		print("data missing")
		return
		
	Global.player_configs[Global.current_slot_index] = temp_config
	
	# 💡 Trigger overlay drawing on the menu
	var menu = get_tree().root.get_node("Root/Menu")
	if menu:
		menu.show_player_slot_overlay(Global.current_slot_index)
	
	emit_signal("setup_confirmed", player_index)  # Notify menu that setup is done
	hide()
	
signal setup_confirmed(player_index: int)


func _on_cancel_button_pressed():
	hide()
