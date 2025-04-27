extends Node

@onready var menu = $Menu
@onready var world = $World
@onready var input_manager = $InputLayer/InputManager

func _ready():
	menu.show()
	world.hide()

func start_game():
	menu.hide()
	world.show()

func back_to_menu():
	world.hide()
	menu.show()
