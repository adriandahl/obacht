extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn")

var players = []
var gap_chance
var gap_buffer # remaining iterations until next chance for gap

var trail_image: Image
var trail_texture: ImageTexture
@onready var canvas = $TrailCanvas

func _ready():
	$GameUI.show()
	var size = get_viewport().get_visible_rect().size
	var image_size = Vector2i(size.x, size.y)

	trail_image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
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
		
		player.position = Vector2(
			randi() % 800 + 100,
			randi() % 400 + 100
		)
		
		player.setup(config)
		players.append(player)
		gap_chance = player.gap_chance

func is_forward_collision(player, trail_image: Image) -> bool:
	var trail_color = Color(0, 0, 0, 1)
	var pos = player.position
	var angle = player.rotation
	var r = player.trail_thickness

	# Only check if player has moved far enough
	if player.last_trail_pos.distance_to(player.position) < 2.0:
		return false
	#print("asdasd")

	var check_offsets = [
		Vector2(-2, -4), Vector2(-1, -4), Vector2(0, -4), Vector2(1, -4), Vector2(2, -4),
		Vector2(-3, -3), Vector2(3, -3),
		Vector2(-4, -2), Vector2(4, -2)
	]

	for offset in check_offsets:
		var rotated = offset.rotated(angle)
		var world_pos = pos + rotated
		var px = int(world_pos.x)
		var py = int(world_pos.y)

		if px >= 0 and py >= 0 and px < trail_image.get_width() and py < trail_image.get_height():
			var test_point = Vector2(px, py)

			var is_fresh = false
			for p in player.drawn_pixels:
				if test_point.distance_squared_to(p) <= r * r:
					is_fresh = true
					break

			if is_fresh:
				continue  # skip this offset

			if trail_image.get_pixel(px, py) != trail_color:
				return true

	return false


func _process(delta):
	for player in players:
		if not player.is_alive:
			continue

		var pos = player.position
		var x = int(pos.x)
		var y = int(pos.y)
		var last_x = int(player.last_trail_pos.x)
		var last_y = int(player.last_trail_pos.y)

		# === Predictive collision check ===
		if is_forward_collision(player, trail_image):
			player.is_alive = false
			update_scoreboard()
			continue
 
		# === Trail Gap Logic ===
		player.gap_length -= 1
		player.gap_cooldown -= 1
		if player.gap_length > 0:
			player.last_trail_pos = player.position
			continue
		if player.gap_cooldown <= 0 and randf() < gap_chance:
			player.gap_length = randi_range(12, 50)
			player.gap_cooldown = player.gap_length + gap_buffer
			player.last_trail_pos = player.position
			continue

		# === Interpolated Trail Drawing ===
		var last_pos = player.last_trail_pos
		var current_pos = player.position
		var distance = last_pos.distance_to(current_pos)
		var step = 1.0

		
		var r = player.trail_thickness
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
								trail_image.set_pixel(tx, ty, player.color)
								player.drawn_pixels.append(Vector2(tx, ty))

		player.last_trail_pos = player.position
		player.drawn_pixels.clear()

	trail_texture.update(trail_image)

func update_scoreboard():
	for player in players:
		if player.is_alive:
			Global.scoreboard[player.name] += 10
	$GameUI.refresh_labels()
	print("Scores updated!")
	print(str(Global.scoreboard))
