extends CanvasLayer

@onready var debug_label: Label = $debug
@onready var time_label : Label = $TimeLabel
@onready var day_screen := $DayTransitionScreen
@onready var day_label := $DayTransitionScreen/Label

# Komponen pause menu
@onready var pause_menu := $PauseMenu
@onready var resume_button := $PauseMenu/MenuPanel/VBoxContainer/ResumeButton
@onready var quit_button := $PauseMenu/MenuPanel/VBoxContainer/QuitButton


func _process(delta: float) -> void:
	if debug_label != null:
		debug_label.text = "FPS: " + String.num(Engine.get_frames_per_second())
	if time_label != null:
		time_label.text = TimeManager.time_text
	if day_label != null:
		day_label.text = TimeManager.day_text
	if day_screen:
		day_screen.visible = TimeManager.is_showing_day_screen


func _ready() -> void:
	if resume_button != null and not resume_button.pressed.is_connected(resume_game):
		resume_button.pressed.connect(resume_game)
	if quit_button != null and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	get_tree().paused = true
	pause_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume_game():
	get_tree().paused = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed():
	resume_game()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
