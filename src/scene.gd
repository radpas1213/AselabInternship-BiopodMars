extends Node
class_name Scene

@export_enum("Menu", "Level") var scene_type: String

@export var scene_name: String

var current_level: String
var current_menu_page: String

## If scene is a menu check this for it to be a sub-menu
@export var is_sub_menu: bool;

func _enter_tree() -> void:
	if scene_type == "Menu":
		SceneManager.current_scene = self
		SceneManager.add_menu_page(self)
		current_menu_page = scene_name
	if scene_type == "Level":
		SceneManager.current_scene = self
		SceneManager.add_level(self)
		current_level = scene_name
