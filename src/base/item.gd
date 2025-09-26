@tool
extends Node2D
class_name Item

@onready var sprite: Sprite2D = $Texture
@onready var interaction: InteractionComponent = $InteractionComponent
#@onready var control: Control = $Control
#@onready var label: Label = control.get_child(0)

## Item data for this item. Data item untuk item ini.
@export var item_resource: ItemData

## ID of the item, can't be changed. ID itemnya, tidak bisa diubah.
@export var item_id:String = ""

## Quantity of the item
@export var item_quantity: int = 1

## Durability of the tool
@export var item_durability: float = 20

## Does item despawn?
@export var item_despawns: bool = true

var item_despawn_time: float = 300
var default_texture: Texture2D

var despawn_timer: Timer

func _ready() -> void:
	interaction.interact = Callable(self, "pickup_item")
	default_texture = sprite.texture
	initialize_item()
	if not Engine.is_editor_hint():
		despawn_timer = Timer.new()
		despawn_timer.wait_time = item_despawn_time
		despawn_timer.one_shot = true
		add_child(despawn_timer)
		despawn_timer.start()
		despawn_timer.timeout.connect(destroy_item)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		initialize_item()

func initialize_item():
	if self != null and item_resource != null:
		if item_resource.texture != null:
			sprite.texture = item_resource.texture
		else:
			sprite.texture = default_texture
		sprite.scale = Vector2(item_resource.item_texture_size, item_resource.item_texture_size)
		item_id = get_id()
		name = item_resource.item_name
	if item_resource == null:
		name = "Item"

func pickup_item():
	var item = {
		"name": item_resource.item_name,
		"id": get_id(),
		"resource": item_resource,
		"type": item_resource.item_type,
		"quantity": item_quantity,
		"max_stack": item_resource.max_stack,
		"durability": item_durability
	}
	Global.player.inventory.add_item(item)
	destroy_item()

func destroy_item():
	get_parent().remove_child(self)
	queue_free()

func get_id() -> String:
	if item_resource != null:
		return "item_" + item_resource.item_name.replace(" ", "_").to_lower()
	return "item"
