extends Node

var player: Player
var camera: Camera2D
var level: Node2D
var HUD: HUD

var default_item_font_size: int = 6

func _ready() -> void:
	set_cursor()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			set_cursor_click()
		else:
			set_cursor()

func _process(delta: float) -> void:
	if ContainerManager.moving_item != null:
		set_cursor_click()

func set_cursor_click():
	Input.set_custom_mouse_cursor(
		preload("res://sprites/UI/cursor_click_32x32.png"),
		Input.CURSOR_ARROW,
		Vector2(8, 8)
	)

func set_cursor():
	Input.set_custom_mouse_cursor(
		preload("res://sprites/UI/cursor_32x32.png"),
		Input.CURSOR_ARROW,
		Vector2(8, 8)
	)

func get_current_scene_name(scene_name: String):
	return get_tree().current_scene != null and get_tree().current_scene.name == scene_name
