extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")

var players = []
var gap_chance

var trail_image: Image
var trail_texture: ImageTexture
@onready var canvas = $TrailCanvas

func _ready():
	var size = get_viewport().get_visible_rect().size
	var image_size = Vector2i(size.x, size.y)

	trail_image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	#trail_image.fill(Color8(18, 0, 28, 255))
	trail_image.fill(Color8(0, 0, 0, 255))
	trail_texture = ImageTexture.create_from_image(trail_image)
	canvas.texture = trail_texture
	spawn_players()
	
func spawn_players():
	for config in Global.player_configs:
		if config == null:
			continue
		
		var player = player_scene.instantiate()
		add_child(player)
		
		player.position = Vector2( # TODO: create valid spawn positions maybe with grid
			randi() % 800 + 100,
			randi() % 400 + 100
		)
		
		player.setup(config)
		players.append(player)
		gap_chance = player.gap_chance

func _process(delta):
	for player in players:
		if not player.is_alive:
			# TODO: handle player death
			continue
		
		var pos = player.position
		var x = int(pos.x)
		var y = int(pos.y)
		
		var forward_vector = Vector2.RIGHT.rotated(player.rotation) * player.speed
		forward_vector = forward_vector.normalized()
		var check_pos = player.position + forward_vector * (player.trail_thickness + 2)  # +2 to be safe
		var check_x = int(check_pos.x)
		var check_y = int(check_pos.y)
		# TODO: check if pixel is enough or if we need area
		
		if check_x >= 0 and check_y >= 0 and check_x < trail_image.get_width() and check_y < trail_image.get_height():
			var pixel_color = trail_image.get_pixel(check_x, check_y)
			if pixel_color != Color(0, 0, 0, 1):  # If not black
				print("Collision for player at", pos)
				player.is_alive = false
				continue

		# try for gap
		player.gap_length -= 1
		if player.gap_length > 0:
			continue
		if randf() < gap_chance:  # e.g. 0.05 = 5% chance to create a tiny gap
			player.gap_length = randi_range(12, 50)
			continue
		
		

		

		# Bounds check
		if x >= 0 and y >= 0 and x < trail_image.get_width() and y < trail_image.get_height():
			var r = player.trail_thickness
			for dx in range(-r, r + 1):
				for dy in range(-r, r + 1):
					if dx * dx + dy * dy <= r * r:
						var px = x + dx
						var py = y + dy
						if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
							trail_image.set_pixel(px, py, player.color)

			

	# After all drawing, update the texture
	trail_texture.update(trail_image)
