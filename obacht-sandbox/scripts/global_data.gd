extends Node

var current_slot_index = -1
var slot_locks = {}
var player_configs = []
var players = []
var scoreboard = {}
var is_gameplay = false

var world: Node = null
var menu: Node = null


#func _ready() -> void:
	#Global.world = $World
	#Global.menu = $Menu

var player_colors = [
	Color.RED, Color.GREEN, Color.BLUE, Color.GOLDENROD,
	Color.MAGENTA, Color.CYAN, Color.DARK_ORANGE, Color.GRAY
]

func reset():
	scoreboard = {}
	players = []
	for config in player_configs:
		config = null
	
	slot_locks = []
	current_slot_index = -1
