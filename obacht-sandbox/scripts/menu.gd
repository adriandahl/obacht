extends Control

@onready var settings_button = $CenterContainer/HBoxContainer/SettingsButton
@onready var help_button = $CenterContainer/HBoxContainer/HelpButton
@onready var start_button = $CenterContainer/HBoxContainerBottom/StartButton
#@onready var setup_popup = $SetupPopup
@onready var setup_popup = $TempPopup


var awaiting_key: String = ""
var temp_config: Dictionary = {}

var player_configs = Global.player_configs
var preset_colors = Global.player_colors

func _ready():
	setup_popup.setup_confirmed.connect(_on_player_setup_confirmed)
	# Hide the popups initially
	#print(GlobalData.testNum)
	setup_popup.hide()
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

func _on_player_setup_confirmed(index: int) -> void:
	var button = get_slot_button(Global.current_slot_index)
	print(index)
	if button:
		button.text = str(Global.player_configs[Global.current_slot_index]["name"])
		Global.current_slot_index = -1

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
	# Here you would load your main scene
	#get_tree().change_scene_to_file("res://scenes/world.tscn")

# Helper function to find correct player button
func get_slot_button(index: int) -> Button:
	match index:
		0:
			return $CenterContainer/SlotVBoxContainer/HBoxContainer2.get_child(0)
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


func _on_color_button_pressed(extra_arg_0: int) -> void:
	pass # Replace with function body.
