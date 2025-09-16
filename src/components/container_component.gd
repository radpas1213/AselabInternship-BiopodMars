extends Node2D
class_name ContainerComponent

## Amount of slots of the actor
@export var slot_amount: int = 13

var container = []

signal container_updated

func _ready() -> void:
	container.resize(slot_amount)
	container_updated.connect(update_container)

func add_item(item: Dictionary):
	var remaining = item["quantity"]
	# Pass 1: fill existing stacks of same item
	for i in range(container.size()):
		if container[i] != null and container[i]["id"] == item["id"] and container[i]["quantity"] < item["max_stack"]:
			var space = item["max_stack"] - container[i]["quantity"]
			var to_add = min(remaining, space)
			container[i]["quantity"] += to_add
			remaining -= to_add
			container_updated.emit()
			if remaining <= 0:
				return true  # fully added	
	# Pass 2: insert into empty slots
	for i in range(container.size()):
		if container[i] == null and remaining > 0:
			var new_stack = item.duplicate(true)
			new_stack["quantity"] = min(remaining, item["max_stack"])
			container[i] = new_stack
			remaining -= new_stack["quantity"]
			container_updated.emit()
			print("item inserted at slot ", i)
			if remaining <= 0:
				return true
	# If we reach here, container is full and some items didn’t fit
	return false

func remove_item(item: Dictionary) -> void:
	container_updated.emit()
	container[container.find(item)] = null

func update_container():
	pass

func ui_clear_container():
	pass
