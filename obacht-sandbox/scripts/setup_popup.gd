extends Window

@onready var name_field = $VBoxContainer/NameEdit
@onready var color_picker = $VBoxContainer/ColorPickerButton
@onready var color_grid = $VBoxContainer/ColorGrid
@onready var left_key_button = $VBoxContainer/KeyGrid/LeftKeyButton
@onready var right_key_button = $VBoxContainer/KeyGrid/RightKeyButton
@onready var item_key_button = $VBoxContainer/KeyGrid/ItemKeyButton
@onready var confirm_button = $VBoxContainer/ButtonGrid/ConfirmButton
@onready var cancel_button = $VBoxContainer/ButtonGrid/CancelButton

var awaiting_key: String = ""
var temp_config: Dictionary = {}

func _ready():
	hide()
	# You can add default color samples dynamically if you want
	#fill_color_grid()

func fill_color_grid():
	var root = get_tree().root.get_child(0)
	for color in root.preset_colors:
		var button = Button.new()
		button.custom_minimum_size = Vector2(50, 50)
		button.modulate = color
		button.pressed.connect(func():
			color_picker.color = color
		)
		color_grid.add_child(button)

func open_with_config(config: Dictionary):
	temp_config = config.duplicate()
	name_field.text = temp_config.get("name", "")
	color_picker.color = temp_config.get("color", Color.WHITE)

	update_key_buttons()
	popup_centered()

func update_key_buttons():
	left_key_button.text = temp_config.get("left", "Set Key")
	right_key_button.text = temp_config.get("right", "Set Key")
	item_key_button.text = temp_config.get("item", "Set Key")

func _on_left_key_button_pressed():
	awaiting_key = "left"
	left_key_button.text = "Press key..."

func _on_right_key_button_pressed():
	awaiting_key = "right"
	right_key_button.text = "Press key..."

func _on_item_key_button_pressed():
	awaiting_key = "item"
	item_key_button.text = "Press key..."

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and awaiting_key != "":
		var keycode = event.keycode
		var key_name = OS.get_keycode_string(keycode)

		match awaiting_key:
			"left":
				temp_config["left"] = key_name
				left_key_button.text = key_name
			"right":
				temp_config["right"] = key_name
				right_key_button.text = key_name
			"item":
				temp_config["item"] = key_name
				item_key_button.text = key_name

		awaiting_key = ""

func _on_confirm_button_pressed():
	temp_config["name"] = name_field.text
	temp_config["color"] = color_picker.color
	# Here you would notify the parent script that setup is finished
	hide()

func _on_cancel_button_pressed():
	hide()
