extends Area2D

#@onready var sprite = $Sprite2D

var left_key
var right_key
var item_key

var speed
var rotation_speed

var is_alive

var is_gap := false 	# holds whether gap is currently being drawn 
var gap_chance = 0.002 	# chance chance of triggering gap per iteration
var gap_length = 0		# remaining iterations for drawing gap.
						# when gap is triggered, pick random gap length in [12,30]
var gap_cooldown
var color
var trail_thickness
var last_pos
var drawn_pixels: Array = []


func setup(config):
	left_key = config["left"]
	right_key = config["right"]
	item_key = config["item"]
	color = config["color"]
	is_alive = true
	trail_thickness = 3.5
	speed = 70
	rotation_speed = 2.5
	gap_cooldown = 50
	last_pos = position

func _process(delta):
	#$Sprite2D.rotation = 0
	last_pos = position
	if not is_alive:
		return
	if Input.is_key_pressed(left_key):
		rotation -= rotation_speed * delta
	if Input.is_key_pressed(right_key):
		rotation += rotation_speed * delta

	position += Vector2.RIGHT.rotated(rotation) * speed * delta
