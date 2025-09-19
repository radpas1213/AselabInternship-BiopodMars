extends Node

var player_inventory: ContainerComponent
var currently_opened_container: ContainerComponent
var player_inventory_ui: ContainerUI
var currently_opened_container_ui: ContainerUI

var moving_item

func transfer_item(from: ContainerComponent, to: ContainerComponent, item: Dictionary, slot_index: int, quantity: int = 1) -> void:
	var source_item = from.container[slot_index]["slot"]
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
		from.container[slot_index]["slot"] = null
	player_inventory.container_updated.emit()
	currently_opened_container.container_updated.emit()

func equip_tool(slot_index: int) -> void:
	var hotbar_slot = player_inventory.container[12]["slot"]
	var item_to_equip = player_inventory.container[slot_index]["slot"]
	if item_to_equip != null:
		# If theres no tool in the hotbar slot move it
		if hotbar_slot == null:
			player_inventory.container[12]["slot"] = item_to_equip
			player_inventory.container[slot_index]["slot"] = null
			player_inventory.container_updated.emit()
			print("Equipped tool to hotbar slot")
		else:
			# If theres an tool in the slot, switch places with each other
			var hotbar_item = hotbar_slot
			player_inventory.container[12]["slot"] = item_to_equip
			player_inventory.container[slot_index]["slot"] = hotbar_item
			player_inventory.container_updated.emit()
			print("Equipped tool and switched places from hotbar slot")
	else:
		printerr("No tool to equip exists!")

func pickup_container_item(slot_index: int, container_ui: ContainerUI):
	if container_ui != null:
		moving_item = container_ui.linked_container.container[slot_index]["slot"]
		container_ui.linked_container.container[slot_index]["slot"] = null
		Global.HUD.moving_item.get_child(0).item_resource = moving_item["resource"]
		Global.HUD.moving_item.get_child(0).item_quantity = moving_item["quantity"]
		Global.HUD.moving_item.get_child(0).item_durability = moving_item["durability"]
	update_container_ui()

func put_down_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item != null:
		container_ui.linked_container.container[slot_index]["slot"] = moving_item
		moving_item = null
		Global.HUD.moving_item.get_child(0).item_resource = null
	update_container_ui()
	
func switch_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item != null:
		# Get the slot reference
		var slot = container_ui.linked_container.container[slot_index]
		# Keep the item currently in the slot
		var slot_item = slot["slot"]
		# Place moving_item into the slot
		slot["slot"] = moving_item
		# Now set moving_item to what was in the slot
		moving_item = slot_item
		# Update HUD preview
		if moving_item != null:
			Global.HUD.moving_item.get_child(0).item_resource = moving_item["resource"]
			Global.HUD.moving_item.get_child(0).item_quantity = moving_item["quantity"]
			Global.HUD.moving_item.get_child(0).item_durability = moving_item["durability"]
		else:
			# Clear HUD preview if nothing is in cursor
			Global.HUD.moving_item.get_child(0).item_resource = null
			Global.HUD.moving_item.get_child(0).item_quantity = 0
			Global.HUD.moving_item.get_child(0).item_durability = 0
	update_container_ui()

func update_container_ui() -> void:
	player_inventory_ui.update_container_ui()
	currently_opened_container_ui.update_container_ui()
	if player_inventory.container[12]["slot"] != null:
		Global.player.held_item.texture = player_inventory.container[12]["slot"]["resource"].texture
		Global.HUD.hotbar.get_child(1).item_resource = player_inventory.container[12]["slot"]["resource"]
	Global.player.holding = player_inventory.container[12]["slot"] != null
	print(player_inventory)
