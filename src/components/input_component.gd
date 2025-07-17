extends Node2D
class_name InputComponent

var move_input_dir: Vector2
var mouse_scroll_dir: float

var interact_button: bool = false

func _input(event: InputEvent) -> void:
	move_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
