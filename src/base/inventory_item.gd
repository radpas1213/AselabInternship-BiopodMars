@tool
extends Control
class_name InventoryItem

@onready var sprite: Sprite2D = $Texture
@onready var count_label: Label = $Count
@onready var durability_bar: TextureProgressBar = $DurabilityBar
@onready var button: Button = $Button
@onready var highlight : ColorRect = $ColorRect
var slot_index: int

## Item data for this item. Data item untuk item ini.
@export var item_resource: ItemData

## Quantity of the item
@export_range(1, 999, 1) var item_quantity: int = 1

## Durability of the tool
@export_range(0, 20, 0.5) var item_durability: float = 20

@export var manual_slot_index_override: int = -1

@export var disable_button: bool = false

var default_texture: Texture2D = ResourceLoader.load("res://sprites/actors/item_placeholder.png")
var draw_hover_rect := false

func _ready() -> void:
	highlight.hide()
	button.disabled = disable_button
	mouse_filter = Control.MOUSE_FILTER_IGNORE if disable_button else Control.MOUSE_FILTER_STOP
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE if disable_button else Control.MOUSE_FILTER_STOP
	sprite.texture = default_texture
	initialize_item()
	if not Engine.is_editor_hint():
		button.pressed.connect(on_press)
		button.gui_input.connect(on_input)
		button.mouse_entered.connect(on_mouse_enter)
		if get_parent() is GridContainer:
			slot_index = get_index()
		if manual_slot_index_override != -1:
			slot_index = manual_slot_index_override

func _process(_delta: float) -> void:
	initialize_item()
	item_visibility()
	if not Engine.is_editor_hint():
		if get_parent().name != "MovingItem":
			highlight.visible = is_mouse_on_slot(button)

func initialize_item():
	if self != null and item_resource != null:
		if item_resource.texture != null:
			sprite.texture = item_resource.texture
		else:
			sprite.texture = default_texture
		sprite.scale = Vector2(item_resource.texture_size, item_resource.texture_size)
		name = item_resource.item_name
		count_label.text = str(item_quantity)
		item_quantity = clamp(item_quantity, 1, item_resource.max_stack)
		durability_bar.progress = item_durability / 20 * 100
	if item_resource == null:
		name = "InventoryItem"
		sprite.texture = default_texture
		sprite.scale = Vector2(1, 1)

func item_visibility():
	var visibility: bool = item_resource != null
	sprite.visible = visibility
	count_label.visible = visibility and item_quantity != 1
	durability_bar.visible = visibility and item_resource.item_type == 2

func on_press():
	var text: String
	if item_resource != null:
		text = (": Slot " + str(slot_index)  +" of item " + item_resource.item_name + " with a quantity of " + str(item_quantity) + " is pressed")
	else:
		text = (": Slot " + str(slot_index) + " is pressed")
	if get_parent().name == "Hotbar":
		print(get_parent(), text)
	else:
		print(get_parent().get_parent(), text)

func on_mouse_enter():
	if Global.player.inputs.rmb_held:
		if ContainerManager.moving_item != null:
			var container_ui := get_parent().get_parent()
			# Handle tool-only restriction
			ContainerManager.put_down_one_container_item(slot_index, container_ui)

func is_mouse_on_slot(slot: Control) -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var slot_rect = slot.get_global_rect()
	return slot_rect.has_point(mouse_pos)

func on_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		var container_ui := get_parent().get_parent()
		# SHIFT CLICK (Quick move)
		if event.button_index == MOUSE_BUTTON_LEFT and Global.player.inputs.shift_held:
			if container_ui.linked_container.container[slot_index]["slot"] != null:
				# Decide where to send it
				var target_container_ui: ContainerUI = null
				if container_ui == ContainerManager.player_inventory_ui:
					if ContainerManager.currently_opened_container_ui != null \
					and ContainerManager.currently_opened_container_ui.visible:
						# Player inventory → send to opened container
						target_container_ui = ContainerManager.currently_opened_container_ui
					else:
						# Only player inventory open → quick move within itself
						target_container_ui = ContainerManager.player_inventory_ui
				else:
					# From container → send to player inventory
					target_container_ui = ContainerManager.player_inventory_ui
				if target_container_ui != null:
					ContainerManager.quick_move_item(slot_index, container_ui, target_container_ui)
				return  # Prevent normal logic from running
		# LEFT CLICK LOGIC
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Case 1: slot has an item
			if item_resource != null:
				if ContainerManager.moving_item == null:
					# Pick up
					ContainerManager.pickup_container_item(slot_index, container_ui)
				else:
					# Same item → try stacking
					if container_ui.linked_container.container[slot_index]["slot"]["resource"] == ContainerManager.moving_item["resource"]:
						var max_stack_size = ContainerManager.moving_item.get("max_stack", 16)
						if container_ui.linked_container.container[slot_index]["slot"]["quantity"] < max_stack_size:
							ContainerManager.put_down_container_item(slot_index, container_ui)
						else:
							# Full → fallback to swap
							if container_ui.player_inventory \
							and ContainerManager.player_inventory.container[slot_index]["tool_only"] \
							and not ContainerManager.moving_item["type"] == 2:
								return
							ContainerManager.switch_container_item(slot_index, container_ui)
					else:
						# Different item → swap
						if container_ui.player_inventory \
						and ContainerManager.player_inventory.container[slot_index]["tool_only"] \
						and not ContainerManager.moving_item["type"] == 2:
							return
						ContainerManager.switch_container_item(slot_index, container_ui)
			# Case 2: slot empty
			else:
				if ContainerManager.moving_item != null:
					# Tool slot restriction
					if container_ui.player_inventory \
					and ContainerManager.player_inventory.container[slot_index]["tool_only"] \
					and not ContainerManager.moving_item["type"] == 2:
						return
					ContainerManager.put_down_container_item(slot_index, container_ui)
		# RIGHT CLICK LOGIC
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if ContainerManager.moving_item != null:
				# Tool slot restriction
				if container_ui.player_inventory \
				and ContainerManager.player_inventory.container[slot_index]["tool_only"] \
				and not ContainerManager.moving_item["type"] == 2:
					return
				ContainerManager.put_down_one_container_item(slot_index, container_ui)
			if item_resource != null:
				if ContainerManager.moving_item == null:
					# Pick up
					ContainerManager.pickup_container_item(slot_index, container_ui, true)
