extends Node

var inventory = []

signal inventory_updated

func _ready() -> void:
	inventory.resize(10)
	inventory_updated.connect(update_inventory)

func add_item(item: Dictionary):
	#var remaining = item["quantity"]
	
	# Pass 1: fill existing stacks of same item
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["id"] == item["id"] and inventory[i]["quantity"] < item["max_stack"]:
			#var space = item["max_stack"] - inventory[i]["quantity"]
			#var to_add = min(remaining, space)
			
			inventory[i]["quantity"] += item["quantity"]
			var unclamped_quantity = inventory[i]["quantity"]
			inventory[i]["quantity"] = clamp(inventory[i]["quantity"], 0, item["max_stack"])
			var remaining_items = unclamped_quantity - inventory[i]["quantity"]
			inventory_updated.emit()
			if remaining_items > 0:
				var remaining_item = item.duplicate(true)
				remaining_item["quantity"] = remaining_items
				return add_item(remaining_item)
			else:
				return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			print("item inserted at slot ", get_index_from_item(item))
			return true

func remove_item(index: int, quantity: int) -> void:
	inventory_updated.emit()

func get_index_from_item(item: Dictionary) -> int:
	return inventory.find(item)

func update_inventory():
	print(inventory)
