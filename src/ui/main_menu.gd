extends Control

func _ready():
	# ini tombol start
	$StartButton.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://levels/main.tscn")
	
	
