extends Node

var levels = []
var menus = []

var current_scene: Scene

func add_level(level: Scene):
	levels.push_front(level)
	print("added ", level.scene_name, " to Levels")
	print(levels)

func remove_level(level: Scene):
	var index = levels.find(level)
	if index != -1:
		levels.remove_at(index)
	print("removed ", level.scene_name, " from Levels")
	
func add_menu_page(menu: Scene):
	menus.push_front(menu)
	print("added ", menu.scene_name, " to the Menus")
	print(menus)

func remove_menu_page(menu: Scene):
	var index = menus.find(menu)
	if index != -1:
		levels.remove_at(index)
	print("removed ", menu.scene_name, " from the Menus")
