@tool
extends Control
class_name InventoryItem

@onready var sprite: Sprite2D = $Texture
@onready var count_label: Label = $Count
@onready var durability_bar: TextureProgressBar = $DurabilityBar
@onready var button: Button = $Button
var slot_index: int

## Item data for this item. Data item untuk item ini.
@export var item_resource: ItemData

## Quantity of the item
@export_range(1, 999, 1) var item_quantity: int = 1

## Durability of the tool
@export_range(0, 20, 0.5) var item_durability: float = 20

@export var manual_slot_index_override: int = -1

var default_texture: Texture2D = ResourceLoader.load("res://sprites/actors/item_placeholder.png")

func _ready() -> void:
	sprite.texture = default_texture
	initialize_item()
	if not Engine.is_editor_hint():
		button.pressed.connect(on_press)
		if get_parent() is GridContainer:
			slot_index = get_index()
		if manual_slot_index_override != -1:
			slot_index = manual_slot_index_override

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		initialize_item()
	else:
		item_visibility()

func initialize_item():
	if self != null and item_resource != null:
		if item_resource.texture != null:
			sprite.texture = item_resource.texture
		else:
			sprite.texture = default_texture
		sprite.scale = Vector2(item_resource.texture_size, item_resource.texture_size)
		name = item_resource.item_name
		count_label.visible = item_quantity != 1
		count_label.text = str(item_quantity)
		item_quantity = clamp(item_quantity, 1, item_resource.max_stack)
		durability_bar.progress = item_durability / 20 * 100
		durability_bar.visible = item_resource.is_tool
	if item_resource == null:
		name = "InventoryItem"
		sprite.texture = default_texture
		sprite.scale = Vector2(1, 1)
		durability_bar.visible = false

func item_visibility():
	var visibility: bool = item_resource != null
	sprite.visible = visibility
	count_label.visible = visibility
	durability_bar.visible = visibility

func on_press():
	print("Slot ", slot_index, " pressed")
