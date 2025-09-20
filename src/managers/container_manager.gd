extends Node

var player_inventory: ContainerComponent
var currently_opened_container: ContainerComponent
var player_inventory_ui: ContainerUI
var currently_opened_container_ui: ContainerUI

var moving_item
var last_interacted_slot: int
var last_interacted_container_ui: ContainerUI

var inventory_opened: bool = false

func pickup_container_item(slot_index: int, container_ui: ContainerUI):
	last_interacted_slot = slot_index
	last_interacted_container_ui = container_ui
	if container_ui != null:
		moving_item = container_ui.linked_container.container[slot_index]["slot"]
		container_ui.linked_container.container[slot_index]["slot"] = null
		init_moving_item()
		container_ui.linked_container.container_updated.emit()

func put_down_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item == null or moving_item["quantity"] <= 0:
		return
	var slot = container_ui.linked_container.container[slot_index]["slot"]
	if slot == null:
		var new_stack = moving_item.duplicate(true)
		container_ui.linked_container.container[slot_index]["slot"] = new_stack
	else:
		if slot["resource"] == moving_item["resource"]:
			var max_stack_size = moving_item.get("max_stack", 16)
			if slot["quantity"] < max_stack_size:
				var remainder = moving_item["quantity"] - slot["quantity"]
				slot["quantity"] += moving_item["quantity"]
				moving_item["quantity"] -= remainder
			else:
				return # slot full
		else:
			return # different item type
	if moving_item["quantity"] <= 0:
		moving_item = null
		Global.HUD.moving_item.get_child(0).item_resource = null
		Global.HUD.moving_item.get_child(0).item_quantity = 0
		Global.HUD.moving_item.get_child(0).item_durability = 0
	else:
		init_moving_item()

	container_ui.linked_container.container_updated.emit()

func switch_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item == null:
		return
	
	var slot = container_ui.linked_container.container[slot_index]
	var slot_item = slot["slot"]
	slot["slot"] = moving_item
	moving_item = slot_item
	init_moving_item()
	container_ui.linked_container.container_updated.emit()

func put_down_one_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item == null or moving_item["quantity"] <= 0:
		return
	
	var slot = container_ui.linked_container.container[slot_index]["slot"]
	if slot == null:
		var new_stack = {
			"resource": moving_item["resource"],
			"quantity": 1,
			"durability": moving_item.get("durability", null),
			"is_tool": moving_item.get("is_tool", false),
			"max_stack": moving_item.get("max_stack", 16)
		}
		container_ui.linked_container.container[slot_index]["slot"] = new_stack
	else:
		if slot["resource"] == moving_item["resource"]:
			var max_stack_size = moving_item.get("max_stack", 16)
			if slot["quantity"] < max_stack_size:
				slot["quantity"] += 1
			else:
				return # slot full
		else:
			return # different item type

	# decrease held stack
	moving_item["quantity"] -= 1
	if moving_item["quantity"] <= 0:
		moving_item = null
		Global.HUD.moving_item.get_child(0).item_resource = null
		Global.HUD.moving_item.get_child(0).item_quantity = 0
		Global.HUD.moving_item.get_child(0).item_durability = 0
	else:
		init_moving_item()

	container_ui.linked_container.container_updated.emit()

func show_container_ui(target_container: ContainerComponent = null) -> void:
	inventory_opened = true
	if target_container != null:
		currently_opened_container_ui.linked_container = target_container
		currently_opened_container = target_container
		currently_opened_container_ui.show_ui()
	player_inventory_ui.show_ui()
	Global.HUD.hotbar.visible = !player_inventory_ui.visible and !currently_opened_container_ui.visible

func hide_container_ui() -> void:
	inventory_opened = false
	if moving_item != null:
		last_interacted_container_ui.linked_container.container[last_interacted_slot]["slot"] = moving_item
		moving_item = null
		init_moving_item()
		update_container_ui()
	currently_opened_container_ui.hide_ui()
	player_inventory_ui.hide_ui()
	Global.HUD.hotbar.visible = !player_inventory_ui.visible and !currently_opened_container_ui.visible

func init_moving_item():
	if moving_item != null:
		Global.HUD.moving_item.get_child(0).item_resource = moving_item["resource"]
		Global.HUD.moving_item.get_child(0).item_quantity = moving_item["quantity"]
		Global.HUD.moving_item.get_child(0).item_durability = moving_item["durability"]
	else:
		# Clear HUD preview if nothing is in cursor
		Global.HUD.moving_item.get_child(0).item_resource = null
		Global.HUD.moving_item.get_child(0).item_quantity = 0
		Global.HUD.moving_item.get_child(0).item_durability = 0

func update_container_ui() -> void:
	player_inventory_ui.update_container_ui()
	currently_opened_container_ui.update_container_ui()
	if player_inventory.container[12]["slot"] != null:
		Global.player.held_item.texture = player_inventory.container[12]["slot"]["resource"].texture
		Global.HUD.hotbar.get_child(1).get_child(0).item_resource = player_inventory.container[12]["slot"]["resource"]
	else:
		Global.HUD.hotbar.get_child(1).get_child(0).item_resource = null
	Global.player.holding = player_inventory.container[12]["slot"] != null
