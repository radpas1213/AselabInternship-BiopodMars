extends Node2D
class_name InputComponent

var move_input_dir: Vector2
var mouse_scroll_dir: float

var interact_button: bool = false

func _input(event: InputEvent) -> void:
	move_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if event.is_action_pressed("inventory"):
		if ContainerManager.inventory_opened == false:
			if not InteractionManager.active_areas.is_empty() and \
			InteractionManager.active_areas.front().owner is StorageContainer:
				ContainerManager.show_container_ui(InteractionManager.active_areas.front().owner.container)
			else:
				ContainerManager.show_container_ui()
		else:
			ContainerManager.hide_container_ui()
