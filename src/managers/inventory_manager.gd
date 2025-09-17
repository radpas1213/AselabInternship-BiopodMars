extends Node

var player_inventory: ContainerComponent
var currently_opened_container: ContainerComponent
var player_inventory_ui: ContainerUI
var currently_opened_container_ui: ContainerUI

func transfer_item(from: ContainerComponent, to: ContainerComponent, item: Dictionary, slot_index: int, quantity: int = 1) -> void:
	var source_item = from.container[slot_index]
	if source_item == null:
		return
	var move_quantity = min(quantity, source_item["quantity"])
	if move_quantity <= 0:
		return
	
	# Reduce from source
	source_item["quantity"] -= move_quantity
	# Make a copy for the destination
	var moving_item = source_item.duplicate(true)
	moving_item["quantity"] = move_quantity
	# Add to target container
	var added = to.add_item(moving_item)
	# If not all were added, put leftovers back
	if added < move_quantity:
		source_item["quantity"] += (move_quantity - added)
	# If source stack is empty, clear the slot
	if source_item["quantity"] <= 0:
		from.container[slot_index] = null

func update_container_ui() -> void:
	player_inventory_ui.update_container_ui()
