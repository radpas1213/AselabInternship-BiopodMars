@tool
extends Node2D
class_name Item

@onready var sprite = $Texture
@onready var label: Label = $Label

## Item data for this item. Data item untuk item ini.
@export var item_resource: ItemData

## ID of the item, can't be changed. ID itemnya, tidak bisa diubah.
@export var item_id:String = ""

func _init() -> void:
	initialize_item()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		initialize_item()

func initialize_item():
	if item_resource.texture != null:
		sprite.texture = item_resource.texture
		sprite.scale = Vector2(item_resource.texture_size, item_resource.texture_size)
	item_id = item_resource.get_id()
	label.text = item_resource.item_name
	
