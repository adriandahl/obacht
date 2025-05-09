extends Control

signal resume_requested
signal quit_to_menu_requested

func _on_continue_pressed():
	resume_requested.emit()

func _on_quit_to_menu_pressed():
	quit_to_menu_requested.emit()
