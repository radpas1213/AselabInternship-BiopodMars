extends Node

var player_inventory: ContainerComponent
var currently_opened_container: ContainerComponent
var player_inventory_ui: ContainerUI
var currently_opened_container_ui: ContainerUI

var moving_item
var last_interacted_slot: int
var last_interacted_container_ui: ContainerUI

var inventory_opened: bool = false

# Container manipulation
func pickup_container_item(slot_index: int, container_ui: ContainerUI, half: bool = false):
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
			"type": slot.get("type", 0) == 2,
			"max_stack": slot.get("max_stack", 64),
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
	var max_stack = item.get("max_stack", 64)

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
		if i == 12 and not item.get("type", 0) == 2:
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
			if i == 12 and not item.get("type", 0) == 2:
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
		currently_opened_container_ui.hide_ui()
		if moving_item != null and last_interacted_container_ui == currently_opened_container_ui:
			last_interacted_container_ui.linked_container.container[last_interacted_slot]["slot"] = moving_item
			moving_item = null
			init_moving_item()
			update_container_ui()
	else:
		inventory_opened = false
		print("inventory currently opened: ", inventory_opened)
		currently_opened_container_ui.hide_ui()
		player_inventory_ui.hide_ui()
		if moving_item != null:
			last_interacted_container_ui.linked_container.container[last_interacted_slot]["slot"] = moving_item
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
	else:
		Global.HUD.hotbar.get_child(1).get_child(0).item_resource = null
	Global.player.holding = player_inventory.container[12]["slot"] != null
