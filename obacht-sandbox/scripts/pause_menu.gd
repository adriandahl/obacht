extends Control

func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	print("resumed!")
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	print("paused!")
	$AnimationPlayer.play("blur")

func testEsc():
	pause() if get_tree().paused == false else resume()


func _on_continue_pressed() -> void:
	resume()

func _on_quit_to_menu_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			testEsc()
