extends Node

var inventory = []

signal inventory_updated

func _ready() -> void:
	inventory.resize(10)
	inventory_updated.connect(update_inventory)

func add_item(item: Dictionary):
	var remaining = item["quantity"]
	
	# Pass 1: fill existing stacks of same item
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["id"] == item["id"] and inventory[i]["quantity"] < item["max_stack"]:
			var space = item["max_stack"] - inventory[i]["quantity"]
			var to_add = min(remaining, space)
			inventory[i]["quantity"] += to_add
			remaining -= to_add
			inventory_updated.emit()
			if remaining <= 0:
				return true  # fully added
	
	# Pass 2: insert into empty slots
	for i in range(inventory.size()):
		if inventory[i] == null and remaining > 0:
			var new_stack = item.duplicate(true)
			new_stack["quantity"] = min(remaining, item["max_stack"])
			inventory[i] = new_stack
			remaining -= new_stack["quantity"]
			inventory_updated.emit()
			print("item inserted at slot ", i)
			if remaining <= 0:
				return true
				
	# If we reach here, inventory is full and some items didn’t fit
	return false

func remove_item(index: int, quantity: int) -> void:
	inventory_updated.emit()

func get_index_from_item(item: Dictionary) -> int:
	return inventory.find(item)

func update_inventory():
	print(inventory)
