extends Control

@onready var resume_button: Button = $MenuPanel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton

func _ready() -> void:
	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	self.visible = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume_game() -> void:
	get_tree().paused = false
	self.visible = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	resume_game()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
