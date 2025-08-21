@tool
extends Node2D
class_name Item

@onready var sprite = $Texture
@onready var interaction = $InteractionComponent
#@onready var control: Control = $Control
#@onready var label: Label = control.get_child(0)

## Item data for this item. Data item untuk item ini.
@export var item_resource: ItemData

## ID of the item, can't be changed. ID itemnya, tidak bisa diubah.
@export var item_id:String = ""

var default_texture: Texture2D

func _ready() -> void:
	default_texture = sprite.texture
	initialize_item()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		initialize_item()

func initialize_item():
	if self != null and item_resource != null:
		if item_resource.texture != null:
			sprite.texture = item_resource.texture
		else:
			sprite.texture = default_texture
		sprite.scale = Vector2(item_resource.texture_size, item_resource.texture_size)
		item_id = get_id()
		#label.text = item_resource.item_name
		name = item_resource.item_name
	
	
func get_id() -> String:
	if item_resource != null:
		return "item_" + item_resource.item_name.replace(" ", "_").to_lower()
	return "item"
