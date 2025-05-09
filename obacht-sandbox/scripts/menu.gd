extends Control

@onready var settings_button = $CenterContainer/HBoxContainer/SettingsButton
@onready var help_button = $CenterContainer/HBoxContainer/HelpButton
@onready var start_button = $CenterContainer/HBoxContainerBottom/StartButton
#@onready var setup_popup = $SetupPopup
@onready var setup_popup = $TempPopup
@onready var player_slot_scene = preload("res://scenes/player_slot.tscn")

signal start_game_pressed


var awaiting_key: String = ""
var temp_config: Dictionary = {}

var player_configs = Global.player_configs
var preset_colors = Global.player_colors

func _ready():
	#setup_popup.hide()
	player_configs.resize(8)
	player_configs.fill(null)
	
	# Assuming your ColorGrid is here:
	var color_buttons = $TempPopup/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/ColorGrid.get_children()

	for i in range(min(color_buttons.size(), preset_colors.size())):
		var button = color_buttons[i]
		var color = preset_colors[i]

		# Make a custom style for each button
		var style = StyleBoxFlat.new()
		style.bg_color = color
		button.add_theme_stylebox_override("normal", style)
		
	#var screen_size = DisplayServer.screen_get_size()
	#if screen_size.x >= 2560 and screen_size.y >= 1440:
		#self.scale = Vector2(2, 2)
		#print("2K+ screen detected. Scaling up x2.")
	#else:
		#print("not caled")

func _on_player_slot_pressed(slot_index):
	print(slot_index)
	Global.current_slot_index = slot_index
	temp_config = {
		"name": "",
		"color": preset_colors[slot_index],  # 🚀 Set default color based on index!
		"left": null,
		"right": null,
		"item": null
	}
	
	if player_configs[slot_index] != null:
		temp_config = player_configs[slot_index].duplicate()
	setup_popup.refresh_color_buttons()
	setup_popup.open_with_config()

func show_player_slot_overlay(index: int):
	var config = Global.player_configs[index]
	if not config:
		return

	#var container = get_slot_container(index)
	var container = get_slot_button(index)

	
	if not container:
		print("ERR: NO CONTAINER")
		return
	container.text = ""

	# Remove old overlay if it exists
	var old = container.get_node_or_null("PlayerSlotOverlay")
	if old:
		old.queue_free()

	var overlay = player_slot_scene.instantiate()
	overlay.name = "PlayerSlotOverlay"
	
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow interaction to pass through
	overlay.custom_minimum_size = get_slot_button(index).size

	# Expand to match
	overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL

	container.add_child(overlay)
	overlay.setup(config)

func get_slot_container(index: int) -> HBoxContainer:
	match index:
		0, 1:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer2
		2, 3:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer3
		4, 5:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer4
		6, 7:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer5
		_:
			return null

func _handle_key_capture(event):
	print("gotem!")
	if event is InputEventKey and event.pressed and not event.echo and awaiting_key != "":
		var keycode = event.keycode
		var key_name = OS.get_keycode_string(keycode)

		match awaiting_key:
			"left":
				temp_config["left"] = keycode
				$TempPopup/MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/LeftKeyButton.text = key_name
			"item":
				temp_config["item"] = keycode
				$TempPopup/MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/ItemKeyButton.text = key_name
			"right":
				temp_config["right"] = keycode
				$TempPopup/MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/RightKeyButton.text = key_name

		awaiting_key = ""


			
	#key_hint.hide()

func _on_start_button_pressed():
	print("Start game pressed!")
	emit_signal("start_game_pressed")

func get_slot_button(index: int) -> Button:
	match index:
		0:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer2.get_child(index)
		1:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer2.get_child(1)
		2:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer3.get_child(0)
		3:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer3.get_child(1)
		4:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer4.get_child(0)
		5:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer4.get_child(1)
		6:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer5.get_child(0)
		7:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer5.get_child(1)
		_:
			return null

func _on_help_button_pressed() -> void:
	$HelpPopup.popup_centered()

func _on_settings_button_pressed() -> void:
	$SettingsPopup.popup_centered()

func clear_player_slots():
	for i in range(Global.player_configs.size()):
		var button = get_slot_button(i)
		if button:
			button.text = "click to join"  # or whatever default

			# Remove overlay if it exists
			var old_overlay = button.get_node_or_null("PlayerSlotOverlay")
			if old_overlay:
				old_overlay.queue_free()

	# Reset config data
	Global.player_configs.fill(null)
	Global.scoreboard.clear()
