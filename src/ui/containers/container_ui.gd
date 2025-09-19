extends Control
class_name ContainerUI

var linked_container: ContainerComponent
var inventory_items = []

@onready var grid: GridContainer = $ItemGrid
@onready var label: Label = $Label

@export var player_inventory: bool = false

func _ready() -> void:
	visible = false
	init_containers()
	for i in find_children("*", "InventoryItem"):
		if i is InventoryItem:
			inventory_items.push_back(i)

func update_container_ui() -> void:
	clear_container_ui()
	if linked_container != null:
		if player_inventory:
			for i in range(linked_container.container.size()):
				if inventory_items[i].slot_index == i:
					if linked_container.container[i]["slot"] != null:
						inventory_items[i].item_resource = linked_container.container[i]["slot"]["resource"]
						inventory_items[i].item_quantity = linked_container.container[i]["slot"]["quantity"]
						inventory_items[i].item_durability = linked_container.container[i]["slot"]["durability"]

func clear_container_ui() -> void:
	for i in range(inventory_items.size()):
		inventory_items[i].item_resource = null
		inventory_items[i].item_quantity = 1
		inventory_items[i].item_durability = 20

func init_containers():
	if player_inventory:
		linked_container = ContainerManager.player_inventory
		ContainerManager.player_inventory_ui = self
	else:
		linked_container = ContainerManager.currently_opened_container
		ContainerManager.currently_opened_container_ui = self
	if linked_container != null:
		label.text = linked_container.container_name_ui

func open_inventory():
	visible = !visible
	Global.HUD.hotbar.visible = !Global.HUD.hotbar.visible
