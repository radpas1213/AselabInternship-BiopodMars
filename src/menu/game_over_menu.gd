extends Control

@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/test_level.tscn") 
	

func _on_quit_pressed() -> void:

	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
