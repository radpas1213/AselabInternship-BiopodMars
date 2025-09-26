extends Control
class_name ContainerUI

var linked_container: ContainerComponent
var inventory_items = []
var mouse_on_gui := false

@onready var label: Label = $Label

@export var player_inventory: bool = false
@export var hotbar_slot: bool = false

func _ready() -> void:
	queue_redraw()
	init_containers()
	for i in find_children("*", "InventoryItem"):
		if i is InventoryItem:
			if not hotbar_slot:
				inventory_items.push_back(i)
			else:
				if linked_container != null:
					inventory_items.resize(linked_container.slot_amount)
					inventory_items[linked_container.hotbar_slots[0]] = i

func _process(delta: float) -> void:
	if visible:
		if player_inventory and not hotbar_slot:
			if $MouseDetect/Control != null:
				mouse_on_gui = is_mouse_on_gui($MouseDetect) or is_mouse_on_gui($MouseDetect/Control)
		elif name == "Hotbar":
			mouse_on_gui = is_mouse_on_gui($MouseDetect)
		else:
			mouse_on_gui = is_mouse_on_gui($MouseDetect)

func is_mouse_on_gui(gui: Control) -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var gui_rect = gui.get_global_rect()
	return gui_rect.has_point(mouse_pos)

func update_container_ui() -> void:
	clear_container_ui()
	if linked_container != null:
		if name == "Hotbar":
			var i = linked_container.hotbar_slots[0]
			if inventory_items[i].slot_index == i:
				if linked_container.container[i]["slot"] != null:
					inventory_items[i].item_resource = linked_container.container[i]["slot"]["resource"]
					inventory_items[i].item_quantity = linked_container.container[i]["slot"]["quantity"]
					inventory_items[i].item_durability = linked_container.container[i]["slot"]["durability"]
		else:
			for i in range(linked_container.container.size()):
				if inventory_items[i].slot_index == i:
					if linked_container.container[i]["slot"] != null:
						inventory_items[i].item_resource = linked_container.container[i]["slot"]["resource"]
						inventory_items[i].item_quantity = linked_container.container[i]["slot"]["quantity"]
						inventory_items[i].item_durability = linked_container.container[i]["slot"]["durability"]

func clear_container_ui() -> void:
	for i in range(inventory_items.size()):
		if inventory_items[i] != null:
			inventory_items[i].item_resource = null
			inventory_items[i].item_quantity = 1
			inventory_items[i].item_durability = 20

func init_containers():
	if player_inventory and not hotbar_slot:
		linked_container = ContainerManager.player_inventory
		ContainerManager.player_inventory_ui = self
	elif not player_inventory:
		ContainerManager.currently_opened_container_ui = self
	if linked_container != null and label != null:
		label.text = linked_container.container_name_ui
	if name != "Hotbar":
		visible = false

func hide_ui():
	visible = false

func show_ui():
	visible = true
