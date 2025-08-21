extends Node

var player: Player
var camera: Camera

var default_item_font_size: int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_current_scene_name(scene_name: String):
	return get_tree().current_scene != null and get_tree().current_scene.name == scene_name
