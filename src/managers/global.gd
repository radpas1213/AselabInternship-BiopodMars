extends Node

var player: Player
var camera: Camera2D
var level: Node2D
var HUD: HUD

var plants: Array = []
var game_started := false
var win_game := true

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
		pass
		#set_cursor_click()

func _physics_process(delta: float) -> void:
	if game_started:
		check_all_plants_dead()

func set_cursor_click():
	Input.set_custom_mouse_cursor(
		preload("res://sprites/UI/cursor_click_32x32.png"),
		Input.CURSOR_POINTING_HAND,
		Vector2(8, 8)
	)

func set_cursor():
	Input.set_custom_mouse_cursor(
		preload("res://sprites/UI/cursor_arrow_32x32.png"),
		Input.CURSOR_ARROW,
		Vector2(8, 8)
	)
	Input.set_custom_mouse_cursor(
		preload("res://sprites/UI/cursor_32x32.png"),
		Input.CURSOR_POINTING_HAND,
		Vector2(8, 8)
	)

func check_all_plants_dead():
	if plants.is_empty():
		return
	for plant in plants:
		if not plant.dead:
			return # At least one alive → don't trigger yet
	plants.clear()
	win_game = false
	get_tree().change_scene_to_file("res://menu/menu_winlose.tscn")
	print("plants all died")

func get_current_scene_name(scene_name: String):
	return get_tree().current_scene != null and get_tree().current_scene.name == scene_name
