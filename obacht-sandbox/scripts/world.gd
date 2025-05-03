extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")

var players = []
var gap_chance
var gap_buffer

var trail_image: Image
var trail_texture: ImageTexture
@onready var canvas = $TrailCanvas

func _ready():
	$GameUI.show()
	var size = get_viewport().get_visible_rect().size
	var image_size = Vector2i(size.x, size.y)

	trail_image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	#trail_image.fill(Color8(18, 0, 28, 255))
	trail_image.fill(Color8(0, 0, 0, 255))
	trail_texture = ImageTexture.create_from_image(trail_image)
	canvas.texture = trail_texture
	
	gap_buffer = 50
	
	spawn_players()
	
func spawn_players():
	for config in Global.player_configs:
		if config == null:
			continue
		
		var player = player_scene.instantiate()
		player.name = config["name"]
		add_child(player)
		
		Global.scoreboard[str(player.name)] = 0
		
		player.position = Vector2( # TODO: create valid spawn positions maybe with grid
			randi() % 800 + 100,
			randi() % 400 + 100
		)
		
		player.setup(config)
		players.append(player)
		gap_chance = player.gap_chance

func _process(_delta):
	#var alive_cnt = 0 # TODO: implement round logic
	for player in players:
		if not player.is_alive:
			# ignore dead players
			continue
		#alive_cnt += 1
		var pos = player.position
		var x = int(pos.x)
		var y = int(pos.y)
		
				# Predictive collision check
		var forward_vector = Vector2.RIGHT.rotated(player.rotation).normalized()
		var check_pos = player.position + forward_vector * (player.trail_thickness * 2.5)

		var check_x = int(check_pos.x)
		var check_y = int(check_pos.y)

		var r = player.trail_thickness
		var collided = false
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				if dx * dx + dy * dy <= r * r:
					var px = check_x + dx
					var py = check_y + dy
					if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
						if trail_image.get_pixel(px, py) != Color(0, 0, 0, 1):
							collided = true
							break
			if collided:
				break

		if collided:
			player.is_alive = false
			update_scoreboard()
			continue

		# try for gap
		player.gap_length -= 1
		player.gap_cooldown -= 1
		if player.gap_length > 0:
			continue
		if player.gap_cooldown <= 0 and randf() < gap_chance:  # e.g. 0.05 = 5% chance to create a tiny gap
			
			player.gap_length = randi_range(12, 50)
			player.gap_cooldown = player.gap_length + gap_buffer
			continue

		# Bounds check # TODO: adjust to actual play zone (without scoreboard)
		if x >= 0 and y >= 0 and x < trail_image.get_width() and y < trail_image.get_height():
			for dx in range(-r, r + 1):
				for dy in range(-r, r + 1):
					if dx * dx + dy * dy <= r * r:
						var px = x + dx
						var py = y + dy
						if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
							trail_image.set_pixel(px, py, player.color)

	# TODO: implement round & winning logic
	#if alive_cnt < 1:
		# round over
	# After all drawing, update the texture
	trail_texture.update(trail_image)

func update_scoreboard():
	for player in players:
		if player.is_alive:
			Global.scoreboard[player.name] += 10
	$GameUI.refresh_labels()
	print("Scores updated!")
	print(str(Global.scoreboard))
