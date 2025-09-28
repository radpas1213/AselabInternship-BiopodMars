extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for light in get_children():
		if light is PointLight2D:
			Global.lights.push_back(light)
