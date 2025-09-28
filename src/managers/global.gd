extends Node

var player: Player
var camera: Camera2D
var level: Node2D
var HUD: HUD

var storages: Array[StorageContainer] = []
var plants: Array[Plant] = []
var lights: Array[PointLight2D] = []
var game_started := false
var win_game := true

var flicker_rng := RandomNumberGenerator.new()
var flicker_timer: Timer

var hostile_habitat: bool = false
var start_hurting_actors: bool = false

func _ready() -> void:
	set_cursor()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			set_cursor_click()
		else:
			set_cursor()

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

func start_light_flicker():
	if flicker_timer == null:
		flicker_timer = Timer.new()
		flicker_timer.one_shot = false
		flicker_timer.wait_time = flicker_rng.randf_range(0.025, 0.1)
		add_child(flicker_timer)
		flicker_timer.timeout.connect(flicker_lights)
		flicker_timer.start()

func stop_light_flicker():
	if flicker_timer != null:
		flicker_timer.stop()
		flicker_timer.queue_free()
		flicker_timer = null
		# Reset lights back to normal (enabled = true)
		for light in lights:
			if light is PointLight2D:
				light.enabled = true

func flicker_lights():
	for light in lights:
		if light is PointLight2D:
			# 70% chance ON, 30% chance OFF each flicker
			light.enabled = flicker_rng.randf() > 0.95

func repopulate_storage_containers():
	for storage in storages:
		storage.loot_table = preload("res://data/loot_tables/storage_container.tres")
		storage.container.populate_with_loot()
	print("repopulating containers")

func get_current_scene_name(scene_name: String):
	return get_tree().current_scene != null and get_tree().current_scene.name == scene_name
