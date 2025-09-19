extends Node2D

var item_name: String = ""
var item_count: int = 0

func setup(name: String, count: int):
	item_name = name
	item_count = count
	$Sprite.texture = preload("res://icon.svg") 
