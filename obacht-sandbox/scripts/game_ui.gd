extends Control

@onready var scoreboard_box = $ScoreboardBox
@onready var scoreboard_labels := [
	$ScoreboardBox/Label0,
	$ScoreboardBox/Label1,
	$ScoreboardBox/Label2,
	$ScoreboardBox/Label3,
	$ScoreboardBox/Label4,
	$ScoreboardBox/Label5,
	$ScoreboardBox/Label6,
	$ScoreboardBox/Label7
]

var label_map: Dictionary = {}

func _ready():
	print("Scoreboard ready!")

	# Hide all labels initially
	for label in scoreboard_labels:
		if label:
			label.hide()

	# Set up labels for each configured player
	for i in range(Global.player_configs.size()):
		var config = Global.player_configs[i]
		if not config:
			continue

		if i >= scoreboard_labels.size():
			push_error("Not enough labels for players!")
			continue

		var label = scoreboard_labels[i]
		if label == null:
			push_error("Label at index %d is null!" % i)
			continue

		var player_name = config["name"]
		var color = config["color"]
		var score = Global.scoreboard.get(player_name, 0)

		label.text = "%s: %d" % [player_name, score]
		label.add_theme_color_override("font_color", color)
		label.show()

		label_map[player_name] = label

func _process(_delta):
	# Create list of player-score-color tuples
	var player_list = []
	for player_name in Global.scoreboard.keys():
		var score = Global.scoreboard[player_name]
		var color = get_player_color(player_name)
		player_list.append({ "name": player_name, "score": score, "color": color })

	# Sort by score descending
	player_list.sort_custom(func(a, b): return b["score"] < a["score"])

	# Update and reorder labels
	for i in range(player_list.size()):
		var player = player_list[i]
		var label = label_map.get(player["name"], null)
		if label:
			label.text = "%s: %d" % [player["name"], player["score"]]
			label.add_theme_color_override("font_color", player["color"])
			scoreboard_box.move_child(label, i)

func refresh_labels():
	for i in range(Global.player_configs.size()):
		var config = Global.player_configs[i]
		if not config:
			continue

		var player_name = config["name"]
		var score = Global.scoreboard.get(player_name, 0)
		print(label_map)
		var label = label_map.get(player_name, null)
		if label:
			label.text = "%s: %d" % [player_name, score]
			label.show()
			print("added score")

func get_player_color(player_name: String) -> Color:
	for config in Global.player_configs:
		if config and config["name"] == player_name:
			return config["color"]
	return Color.WHITE

func build_label_map():
	label_map.clear()
	for i in range(Global.player_configs.size()):
		var config = Global.player_configs[i]
		if not config:
			continue
		var player_name = config["name"]
		var label = scoreboard_labels[i]
		label_map[player_name] = label

func clear_scoreboard_ui():
	label_map.clear()
	for label in scoreboard_labels:
		label.text = ""
		label.hide()
