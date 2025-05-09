extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")
var gap_chance
var gap_buffer # remaining iterations until next chance for gap

var trail_image: Image
var trail_texture: ImageTexture
var ui_margin = 200 # for displacing playing field
@onready var size = get_viewport().get_visible_rect().size
#@onready var area = Vector2(size.y + ui_margin, size.y)
var safety_margin = 50
var existing_positions: Array = []
var min_distance = 100  # Minimum distance between player spawns

@onready var sprite_texture = preload("res://assets/player_head.png")

# player hitbox
var check_offsets = [
			Vector2(4,  1), Vector2(4,  0), Vector2(4, -1),
		Vector2(3.5,  2), 						 Vector2(3.5, -2),
]
var debug_points: Array = [] # visualize hitbox

@onready var canvas = $TrailCanvas

func _ready():
	$GameUI.show()
	var size = get_viewport().get_visible_rect().size
	var image_size = Vector2i(size.x, size.y)

	trail_image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	trail_image.fill(Color8(0, 0, 0, 255))
	
	# Draw yellow playfield border (2px thick)
	var border_color = Color.YELLOW
	var thickness = 4


	for x in range(image_size.y):
		for t in range(thickness):
			trail_image.set_pixel(x + ui_margin, t, border_color)  # Top
			trail_image.set_pixel(x + ui_margin, image_size.y - 1 - t, border_color)  # Bottom

	for y in range(image_size.y):
		for t in range(thickness):
			trail_image.set_pixel(t + ui_margin, y, border_color)  # Left
			trail_image.set_pixel(image_size.y - 1 - t + ui_margin, y, border_color)  # Right
	
	trail_texture = ImageTexture.create_from_image(trail_image)
	canvas.texture = trail_texture

	
	gap_buffer = 50
	update_scoreboard()
	
	#if Global.player_configs.any(func(p): return p != null):
		#spawn_players()
	
func spawn_players():
	for config in Global.player_configs:
		if config == null:
			continue
		
		var player = player_scene.instantiate()
		player.name = config["name"]
		player.position = get_safe_spawn_position(existing_positions, size, safety_margin)
		existing_positions.append(player.position)
		player.rotation = randf_range(0, 2 * PI)
		add_child(player)
		
		player.setup(config)
		Global.scoreboard[str(player.name)] = 0
		Global.players.append(player)
		gap_chance = player.gap_chance



func get_safe_spawn_position(existing_positions: Array, size: Vector2, margin: int, max_attempts := 50) -> Vector2:
	var attempt = 0
	while attempt < max_attempts:
		var pos = Vector2(
			randi_range(ui_margin + margin, size.y + ui_margin - margin),  # Use size.y + margin for right edge
			randi_range(margin, size.y - margin)  # y stays the same
		)

		var too_close = false
		for other in existing_positions:
			if pos.distance_to(other) < min_distance:
				too_close = true
				break

		if not too_close:
			return pos

		attempt += 1

	return size / 2  # fallback



func is_forward_collision(player, trail_image: Image) -> bool:
	var trail_color = Color(0, 0, 0, 1)
	var pos = player.position
	var angle = player.rotation
	var direction = Vector2.RIGHT.rotated(angle).normalized()
	#var forward_offset = direction * 1

	debug_points.clear()

	for offset in check_offsets:
		var rotated = offset.rotated(angle)
		#var world_pos = pos + forward_offset + rotated
		var world_pos = pos + rotated
		debug_points.append(world_pos)
		var px = int(world_pos.x)
		var py = int(world_pos.y)

		if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
			if trail_image.get_pixel(px, py) != Color.BLACK:
				return true
	
	return false

func _process(delta):
	queue_redraw()
	for player in Global.players:
		if not player.is_alive:
			continue

		# === Predictive collision check ===
		if is_forward_collision(player, trail_image):
			player.is_alive = false
			update_scoreboard()
			continue

		# === Trail Gap Logic ===
		player.gap_length -= 1
		player.gap_cooldown -= 1
		var in_gap = false
		if player.gap_length > 0:
			in_gap = true
		elif player.gap_cooldown <= 0 and randf() < gap_chance:
			player.gap_length = randi_range(12, 50)
			player.gap_cooldown = player.gap_length + gap_buffer
			in_gap = true

		var r = player.trail_thickness
		var last_pos = player.last_pos
		var current_pos = player.position
		var distance = last_pos.distance_to(current_pos)
		var step = 1.0
		var trail_color = player.color
		
		if not in_gap:
			for t in range(0, int(distance), step):
				var interp_pos = last_pos.lerp(current_pos, t / distance)
				var px = int(interp_pos.x)
				var py = int(interp_pos.y)

				if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
					for dx in range(-r, r + 1):
						for dy in range(-r, r + 1):
							if dx * dx + dy * dy <= r * r:
								var tx = px + dx
								var ty = py + dy
								if tx >= 0 and ty >= 0 and tx < trail_image.get_width() and ty < trail_image.get_height():
									trail_image.set_pixel(tx, ty, trail_color)
									player.drawn_pixels.append(Vector2(tx, ty))
			


		player.last_pos = player.position
		player.drawn_pixels.clear()

	trail_texture.update(trail_image)

func update_scoreboard():
	for player in Global.players:
		if player.is_alive:
			Global.scoreboard[player.name] += 10
	$GameUI.refresh_labels()


#func _draw():
	#for point in debug_points:
		#draw_circle(point, 1, Color(1, 0, 1))  # bright purple
	
	#for player in players:
		#draw_texture(sprite_texture, player.position - sprite_texture.get_size() / 2)
