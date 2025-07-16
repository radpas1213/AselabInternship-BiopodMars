extends Node2D
class_name InputComponent

var input_dir: Vector2

func _input(event: InputEvent) -> void:
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
