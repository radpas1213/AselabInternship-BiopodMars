extends Node

var player_inventory: ContainerComponent
var currently_opened_container: ContainerComponent
var player_inventory_ui: ContainerUI
var currently_opened_container_ui: ContainerUI

var currently_hovered_slot_index := -1

var moving_item
var last_interacted_slot: int
var last_interacted_container_ui: ContainerUI

var inventory_opened: bool = false

func give_player_tools():
	var can = preload("res://data/items/item_watering_can.tres")
	var tool = preload("res://data/items/item_repair_tool.tres")
	var cancan = {
		"name": can.item_name,
		"resource": can,
		"type": can.item_type,
		"quantity": 1,
		"max_stack": can.max_stack,
		"durability": 0
	}
	var toool = {
		"name": tool.item_name,
		"resource": tool,
		"type": tool.item_type,
		"quantity": 1,
		"max_stack": tool.max_stack,
		"durability": randf_range(15.0, 18.0)
	}
	if ContainerManager.player_inventory != null:
		ContainerManager.player_inventory.container[0]["slot"] = toool
		ContainerManager.player_inventory.container[1]["slot"] = cancan

func is_player_holding_water_can() -> bool:
	if player_inventory != null:
		if player_inventory.container[12]["slot"] != null and\
		player_inventory.container[12]["slot"]\
		["resource"] == preload("res://data/items/item_watering_can.tres"):
			return true
	return false

func is_player_holding_repair_tool() -> bool:
	if player_inventory != null:
		if player_inventory.container[12]["slot"] != null and\
		player_inventory.container[12]["slot"]\
		["resource"] == preload("res://data/items/item_repair_tool.tres"):
			return true
	return false

func get_item_in_hotbar() -> Dictionary:
	if player_inventory != null:
		if player_inventory.container[12]["slot"] != null:
			return player_inventory.container[12]["slot"]
	return {
		"quantity" = 0,
		"durability" = 0
	}

func check_for_items_for_repairs(items_needed: Dictionary) -> Dictionary:
	var results: Dictionary = {}
	for item_id in items_needed.keys():
		var count: int = 0
		var needed: int = items_needed[item_id]
		# Load the resource once per item_id
		for slot_data in player_inventory.container:
			var slot = slot_data["slot"]
			if slot != null and slot.has("resource") and slot["resource"] != null:
				# Compare by path instead of raw reference
				if slot["resource"] == item_id:
					count += slot["quantity"]
					if count >= needed:
						break
		results[item_id] = clamp(count, 0, needed)
	return results

func use_energy_cell_for_repair_tool(tool) -> void:
	for slot_data in player_inventory.container:
		var slot = slot_data["slot"]
		if slot != null and slot["resource"] == preload("res://data/items/item_energy_cell.tres"):
			
			# Recharge repair tool durability
			var recharge_value = 20 / 3
			if tool["durability"] < 20.0 - recharge_value:
				tool["durability"] += recharge_value
				# Consume one energy cell
				slot["quantity"] -= 1
				player_inventory.container_updated.emit()
				Global.HUD.show_notif_label("Repair tool recharged with one Energy Cell.", true)
			else:
				Global.HUD.show_notif_label("Repair tool has enough durability.", true)
			return

func drop_item(slot_index: int, container_ui: ContainerUI, hover_drop: bool = false):
	if container_ui == null:
		return
	var target_slot
	if hover_drop:
		target_slot = container_ui.linked_container.container[slot_index]["slot"]
		if target_slot == null:
			return
	if not hover_drop:
		if player_inventory_ui.mouse_on_gui:
			return
		if currently_opened_container_ui.mouse_on_gui:
			return
	# Spawn dropped item
	var dropped_item = preload("res://actors/item.tscn").instantiate()
	if not hover_drop:
		dropped_item.item_resource = moving_item["resource"]
		dropped_item.item_quantity = moving_item["quantity"]
		dropped_item.item_durability = moving_item["durability"]
	else:
		dropped_item.item_resource = target_slot["resource"]
		dropped_item.item_quantity = target_slot["quantity"]
		dropped_item.item_durability = target_slot["durability"]
	dropped_item.position = Global.player.position
	Global.level.find_child("Items").add_child(dropped_item)
	# Remove selected item
	if not hover_drop:
		if moving_item != null:
			moving_item = null
			init_moving_item()
	else:
		if target_slot != null:
			container_ui.linked_container.container[slot_index]["slot"] = null
			container_ui.linked_container.container_updated.emit()

func drop_moving_item_full_inventory(item) -> void:
	var dropped_item = preload("res://actors/item.tscn").instantiate()
	dropped_item.item_resource = item["resource"]
	dropped_item.item_quantity = item["quantity"]
	dropped_item.item_durability = item.get("durability", null)
	dropped_item.position = Global.player.position
	Global.level.find_child("Items").add_child(dropped_item)

# Container manipulation
func pickup_container_item(slot_index: int, container_ui: ContainerUI, half: bool = false):
	print("call")
	last_interacted_slot = slot_index
	last_interacted_container_ui = container_ui
	if container_ui == null:
		return
	if container_ui.hotbar_slot:
		return
	var slot = container_ui.linked_container.container[slot_index]["slot"]
	if slot == null:
		return
	if half:
		var half_amount = int(ceil(slot["quantity"] / 2.0))
		# Cursor gets half
		moving_item = {
			"resource": slot["resource"],
			"quantity": half_amount,
			"durability": slot.get("durability", null),
			"type": slot["type"],
			"max_stack": slot.get("max_stack", 16),
		}
		# Reduce slot by half
		slot["quantity"] -= half_amount
		if slot["quantity"] <= 0:
			container_ui.linked_container.container[slot_index]["slot"] = null
	else:
		# Normal full pickup
		moving_item = slot
		container_ui.linked_container.container[slot_index]["slot"] = null
	init_moving_item()
	container_ui.linked_container.container_updated.emit()

func put_down_container_item(slot_index: int, container_ui: ContainerUI):
	if moving_item == null or moving_item["quantity"] <= 0:
		return
	var slot = container_ui.linked_container.container[slot_index]["slot"]
	if slot == null:
		# Place full moving stack into empty slot
		var new_stack = moving_item.duplicate(true)
		container_ui.linked_container.container[slot_index]["slot"] = new_stack
		moving_item = null
		init_moving_item()
	else:
		if slot["resource"] == moving_item["resource"]:
			var max_stack_size = moving_item.get("max_stack", 16)
			if slot["quantity"] < max_stack_size:
				# How many can fit in this slot?
				var space_left = max_stack_size - slot["quantity"]
				var transfer_amount = min(space_left, moving_item["quantity"])
				# Add to slot
				slot["quantity"] += transfer_amount
				# Remove from moving
				moving_item["quantity"] -= transfer_amount
				# If cursor stack is empty, clear it
				if moving_item["quantity"] < 1:
					moving_item = null
				init_moving_item()
			else:
				return # slot full, nothing happens
		else:
			return # different item type
	container_ui.linked_container.container_updated.emit()

func quick_move_item(slot_index: int, from_container_ui: ContainerUI, to_container_ui: ContainerUI):
	var slot = from_container_ui.linked_container.container[slot_index]["slot"]
	if slot == null:
		return
	if not to_container_ui.visible:
		return

	var item = slot
	var max_stack = item.get("max_stack", 16)

	# Detect if only the player inventory is open
	var only_player_inventory_open = to_container_ui == ContainerManager.player_inventory_ui \
		and not ContainerManager.currently_opened_container_ui.visible

	# --- Tool Quick Move Logic ---
	if to_container_ui == ContainerManager.player_inventory_ui and item.get("type", 0) == 2 and slot_index != 12:
		var hotbar_slot = to_container_ui.linked_container.container[12]["slot"]

		if only_player_inventory_open:
			# Only player inventory open → hotbar is the only valid destination
			if hotbar_slot == null:
				# Move tool to hotbar
				to_container_ui.linked_container.container[12]["slot"] = item
				from_container_ui.linked_container.container[slot_index]["slot"] = null
				to_container_ui.linked_container.container_updated.emit()
				from_container_ui.linked_container.container_updated.emit()
			# If hotbar occupied → do nothing
			return
		else:
			# Container is open → prioritize hotbar only if empty
			if hotbar_slot == null:
				to_container_ui.linked_container.container[12]["slot"] = item
				from_container_ui.linked_container.container[slot_index]["slot"] = null
				to_container_ui.linked_container.container_updated.emit()
				from_container_ui.linked_container.container_updated.emit()
				return
			# If hotbar has any item → skip it and fall through to normal logic

	# --- Normal quick move behavior ---
	# Try merging into existing stacks first
	for i in range(to_container_ui.linked_container.container.size()):
		# Skip hotbar slot for non-tools
		if i == 12 and item["type"] != 2:
			continue
		var target_slot = to_container_ui.linked_container.container[i]["slot"]
		if target_slot != null and target_slot["resource"] == item["resource"]:
			var free_space = max_stack - target_slot["quantity"]
			if free_space > 0:
				var transfer = min(free_space, item["quantity"])
				target_slot["quantity"] += transfer
				item["quantity"] -= transfer
				if item["quantity"] <= 0:
					from_container_ui.linked_container.container[slot_index]["slot"] = null
					from_container_ui.linked_container.container_updated.emit()
					to_container_ui.linked_container.container_updated.emit()
					return

	# If items remain → put them in first empty slot
	if item["quantity"] > 0:
		for i in range(to_container_ui.linked_container.container.size()):
			# Skip hotbar slot for non-tools
			if i == 12 and item.get("type", 0) != 2:
				continue
			# Skip hotbar if container is open and slot already filled
			if i == 12 and not only_player_inventory_open and to_container_ui.linked_container.container[12]["slot"] != null:
				continue
			var target_slot = to_container_ui.linked_container.container[i]["slot"]
			if target_slot == null:
				to_container_ui.linked_container.container[i]["slot"] = item
				from_container_ui.linked_container.container[slot_index]["slot"] = null
				to_container_ui.linked_container.container_updated.emit()
				from_container_ui.linked_container.container_updated.emit()
				return
	# If no space → do nothing

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
			"type": moving_item.get("type", 0) == 2,
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
	print("inventory currently opened: ", inventory_opened)
	if target_container != null:
		currently_opened_container_ui.linked_container = target_container
		currently_opened_container = target_container
		currently_opened_container_ui.show_ui()
		currently_opened_container_ui.linked_container.container_updated.emit()
		print("container ui shown")
	player_inventory_ui.show_ui()
	player_inventory_ui.linked_container.container_updated.emit()
	Global.HUD.hotbar.visible = !player_inventory_ui.visible and !currently_opened_container_ui.visible

func hide_container_ui(hide_container_only: bool = false) -> void:
	if hide_container_only:
		currently_opened_container_ui.linked_container.owner.close_sound.play()
		currently_opened_container_ui.hide_ui()
		if moving_item != null and last_interacted_container_ui == currently_opened_container_ui:
			# Check tool-only restriction
			var slot_data = last_interacted_container_ui.linked_container.container[last_interacted_slot]
			var is_tool_only = slot_data.get("tool_only", false)
			if is_tool_only and not moving_item.get("is_tool", false):
				# Drop item instead of forcing into hotbar
				drop_moving_item_full_inventory(moving_item)
				moving_item = null
				init_moving_item()
			else:
				slot_data["slot"] = moving_item
				moving_item = null
				init_moving_item()
			update_container_ui()
	else:
		inventory_opened = false
		print("inventory currently opened: ", inventory_opened)
		currently_opened_container_ui.hide_ui()
		player_inventory_ui.hide_ui()
		if moving_item != null:
			var slot_data = last_interacted_container_ui.linked_container.container[last_interacted_slot]
			var is_tool_only = slot_data.get("tool_only", false)
			if is_tool_only and not moving_item.get("is_tool", false):
				# Drop item instead of forcing into hotbar
				drop_moving_item_full_inventory(moving_item)
				moving_item = null
				init_moving_item()
			else:
				slot_data["slot"] = moving_item
				moving_item = null
				init_moving_item()
			update_container_ui()
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
		Global.HUD.hotbar.get_child(1).get_child(0).item_durability = player_inventory.container[12]["slot"]["durability"]
	else:
		Global.HUD.hotbar.get_child(1).get_child(0).item_resource = null
	Global.player.holding = player_inventory.container[12]["slot"] != null
