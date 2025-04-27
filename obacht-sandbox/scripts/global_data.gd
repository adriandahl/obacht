extends Node

var current_slot_index = -1
var slot_locks = {}

var player_configs = []

var player_colors: Array = [
	Color(1, 0, 0),    # Red
	Color(0, 0, 1),    # Blue
	Color(0.5, 0.5, 0.5),    # Grey
	Color(0, 1, 0),    # Green
	Color(1, 0, 1),    # Magenta
	Color(0, 1, 1),    # Cyan
	Color(1, 0.5, 0),  # Orange
	Color(0.5, 0, 0.5) # Purple
]
