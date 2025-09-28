extends StaticBody2D

signal generator_changed

enum RepairStates {
	REPAIRED,
	NEEDS_REPAIRS,
	BROKEN
}
var repair_state: RepairStates = RepairStates.NEEDS_REPAIRS:
	set(new_repair_state):
		repair_state = new_repair_state
		generator_changed.emit()
@onready var interaction: InteractionComponent = $InteractionComponent

@export var items_needed: Dictionary = {}
var inventory_items: Array[InventoryItem] = []
var durability_needed_for_repair: float = 15.0

func _ready() -> void:
	TimeManager.day_changed.connect(worsen_generator)
	generator_changed.connect(on_generator_state_changed)
	interaction.on_interact_press = Callable(self, "press")
	interaction.on_interact_release = Callable(self, "release")
	interaction.interact = Callable(self, "interact")
	interaction.on_enter = Callable(self, "on_enter")
	interaction.on_exit = Callable(self, "on_exit")
	Global.HUD.items_needed_repair_hud.hide()

func _physics_process(delta: float) -> void:
	interaction.trigger_interaction = ContainerManager.is_player_holding_repair_tool() and\
	has_all_items_for_repair(items_needed) and ContainerManager.get_item_in_hotbar()["durability"] > durability_needed_for_repair
	update_items_needed_modulate()

func worsen_generator():
	if repair_state != RepairStates.BROKEN:
		repair_state += 1
	print("generator worsened")

func assign_items_needed_for_repair():
	if repair_state == RepairStates.BROKEN:
		items_needed = {
			preload("res://data/items/item_wiring_unit.tres"): 5,
			preload("res://data/items/item_control_chip.tres"): 3,
			preload("res://data/items/item_screw.tres"): 6,
			preload("res://data/items/item_iron.tres"): 3,
			preload("res://data/items/item_silicone.tres"): 5
		}
	elif repair_state == RepairStates.NEEDS_REPAIRS:
		items_needed = {
			preload("res://data/items/item_wiring_unit.tres"): 2,
			preload("res://data/items/item_control_chip.tres"): 1,
			preload("res://data/items/item_screw.tres"): 3,
			preload("res://data/items/item_iron.tres"): 2,
			preload("res://data/items/item_silicone.tres"): 2
		}
	else:
		items_needed = {}
	setup_items_needed_for_repair_hud()

func on_enter():
	assign_items_needed_for_repair()
	if repair_state != RepairStates.REPAIRED:
		Global.HUD.items_needed_repair_hud.show()
		Global.HUD.show_notif_label("Items needed to repair:")

func on_exit():
	Global.HUD.items_needed_repair_hud.hide()
	Global.HUD.hide_notif_label()

func interact():
	$AudioStreamPlayer2D.stop()
	take_items_from_inventory()
	ContainerManager.get_item_in_hotbar()["durability"] -= durability_needed_for_repair
	ContainerManager.player_inventory_ui.linked_container.container_updated.emit()
	if repair_state != RepairStates.REPAIRED:
		repair_state -= 1
	if repair_state == RepairStates.NEEDS_REPAIRS:
		Global.HUD.show_notif_label("Generator fully repaired!", true)
	setup_items_needed_for_repair_hud()
	if repair_state == RepairStates.REPAIRED:
		Global.HUD.items_needed_repair_hud.hide()
	
func take_items_from_inventory():
	# Only allow if requirements are met
	if not has_all_items_for_repair(items_needed):
		print("Not enough items to repair!")
		return
	# Deduct items from player inventory
	for item_res in items_needed.keys():
		var needed : int = items_needed[item_res]
		var remaining : int = needed
		for slot_data in ContainerManager.player_inventory.container:
			if remaining <= 0:
				break
			var slot = slot_data["slot"]
			if slot != null and slot["resource"] == item_res:
				if slot["quantity"] > remaining:
					# Reduce stack
					slot["quantity"] -= remaining
					remaining = 0
				else:
					# Remove full stack
					remaining -= slot["quantity"]
					slot_data["slot"] = null
	# Update UI
	ContainerManager.player_inventory.container_updated.emit()
	print("Items taken for repair!")


func clear_items_needed_for_repair_hud():
	for items in inventory_items:
		items.queue_free()
	inventory_items.clear()

func setup_items_needed_for_repair_hud():
	clear_items_needed_for_repair_hud()
	for items in items_needed.keys():
		var inv_item := preload("res://actors/ui/inventory_item.tscn").instantiate()
		inv_item.item_resource = items
		inv_item.item_quantity = items_needed[items]
		inventory_items.push_back(inv_item)
		Global.HUD.items_needed_repair_hud.find_child("ItemsNeeded").add_child(inv_item)
		inv_item.find_child("Texture").modulate = Color(1.0, 0.3, 0.3, 1)
		inv_item.disable_button = true

func update_items_needed_modulate():
	if inventory_items.is_empty():
		return
	# Get the counts of items the player actually has
	var owned_items := ContainerManager.check_for_items_for_repairs(items_needed)
	for inv_item in inventory_items:
		if inv_item.item_resource == null:
			continue
		var item_res: Resource = inv_item.item_resource
		var needed: int = items_needed[item_res]
		var owned: int = owned_items[item_res]
		# If player has enough, make it normal color
		if owned >= needed:
			inv_item.find_child("Texture").modulate = Color(1, 1, 1, 1)  # reset to normal
		else:
			inv_item.find_child("Texture").modulate = Color(1.0, 0.3, 0.3, 1)  # still missing

func has_all_items_for_repair(items_needed: Dictionary) -> bool:
	# Get the items we actually have (clamped to needed amounts)
	var owned_items := ContainerManager.check_for_items_for_repairs(items_needed)
	for item_res in items_needed.keys():
		var needed : int = items_needed[item_res]
		var owned : int = owned_items[item_res]
		if owned < needed:
			return false  # Missing some items
	return true  # All requirements met

func on_generator_state_changed():
	if repair_state == RepairStates.BROKEN:
		Global.start_light_flicker()
		Global.hostile_habitat = true
		await get_tree().create_timer(15).timeout
		Global.start_hurting_actors = true
	else:
		Global.stop_light_flicker()
		Global.hostile_habitat = false
		Global.start_hurting_actors = false

func label_text() -> String:
	if not ContainerManager.is_player_holding_repair_tool():
		if repair_state == RepairStates.REPAIRED:
			return ""
		else:
			return "Repair tool needed to interact"
	else:
		if has_all_items_for_repair(items_needed):
			if repair_state == RepairStates.REPAIRED:
				return ""
			if repair_state == RepairStates.NEEDS_REPAIRS:
				return "Hold R to repair Generator"
			elif repair_state == RepairStates.BROKEN:
				return "Urgent care needed!!! \nHold R to repair broken Generator"
		else:
			if repair_state != RepairStates.REPAIRED:
				return "Item requirements aren't met. \nCannot repair"
	return ""

func press():
	$AudioStreamPlayer2D.play()

func release():
	$AudioStreamPlayer2D.stop()
