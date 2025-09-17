extends Control
class_name ContainerUI

var linked_container: ContainerComponent
var inventory_items = []

@onready var grid: GridContainer = $ItemGrid

@export var player_inventory: bool = false

func _ready() -> void:
	if player_inventory:
		linked_container = InventoryManager.player_inventory
		InventoryManager.player_inventory_ui = self
	else:
		linked_container = InventoryManager.currently_opened_container
		InventoryManager.currently_opened_container_ui = self
	#print(linked_container)
	for i in find_children("*", "InventoryItem"):
		if i is InventoryItem:
			inventory_items.push_back(i)
	#print(name, ": ", inventory_items)

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
