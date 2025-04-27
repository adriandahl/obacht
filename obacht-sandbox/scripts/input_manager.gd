extends Control

@export var menu: Node

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return
	if menu and menu.has_method("handle_key_capture"):
		menu.call("handle_key_capture", event)
