extends Node2D
class_name InputComponent

var move_input_dir: Vector2
var mouse_scroll_dir: float

var interact_button: bool = false
var interact_held: bool = false
var shift_held: bool = false
var ctrl_held: bool = false
var lmb_held: bool = false
var rmb_held: bool = false

func _input(event: InputEvent) -> void:
	move_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if event.is_action_pressed("inventory"):
		if ContainerManager.inventory_opened == false:
			ContainerManager.show_container_ui()
		else:
			ContainerManager.hide_container_ui()
	
	shift_held = Input.is_key_pressed(KEY_SHIFT)
	ctrl_held = Input.is_key_pressed(KEY_CTRL)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			lmb_held = event.is_pressed()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rmb_held = event.is_pressed()
