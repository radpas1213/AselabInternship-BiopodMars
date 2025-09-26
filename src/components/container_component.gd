extends Node2D
class_name ContainerComponent

## Set container slots and properties
@export var slot_amount: int = 12
## Slots with this index will be considered hotbars (only tools allowed)
@export var hotbar_slots: PackedInt64Array
## Loot table of this container (ex: storage containers, mining stations)
@export var loot_table: LootTable
## Name of the container (For UIs)
@export var container_name_ui: String = "Container"

var container = []

signal container_updated

func _ready() -> void:
	initialize_container_slots()
	container_updated.connect(update_container)

func add_item(item: Dictionary) -> bool:
	var slot_index
	var remaining = item["quantity"]
	# --- Special case: tools → try hotbar first (slot 12) ---
	if item.get("type", 0) == 2:
		var hotbar_slot = container[12]["slot"]
		if hotbar_slot == null:
			# Insert tool directly into slot 12
			var new_stack = item.duplicate(true)
			new_stack["quantity"] = min(remaining, item["max_stack"])
			container[12]["slot"] = new_stack
			remaining -= new_stack["quantity"]
			container_updated.emit()
			slot_index = 12
			print("Inserted item ", item["name"], " in container of ", owner.name, " with a count of ", item["quantity"], " at slot ",slot_index)
			if remaining <= 0:
				return true
		elif hotbar_slot["resource"] == item["resource"] and hotbar_slot["quantity"] < item["max_stack"]:
			# Merge into existing tool stack in slot 12
			var space = item["max_stack"] - hotbar_slot["quantity"]
			var to_add = min(remaining, space)
			hotbar_slot["quantity"] += to_add
			remaining -= to_add
			container_updated.emit()
			print("Inserted item ", item["name"], " in container of ", owner.name, " with a count of ", item["quantity"], " at slot ",slot_index)
			if remaining <= 0:
				return true
		# If hotbar slot is full or contains another item → fall through
	# --- Pass 1: fill existing stacks of same item ---
	for i in range(container.size()):
		if container[i]["slot"] != null \
		and container[i]["slot"]["resource"] == item["resource"] \
		and container[i]["slot"]["quantity"] < item["max_stack"]:
			# Respect tool_only slot restriction
			if container[i]["tool_only"] and not item.get("type", 0) == 2:
				continue
			var space = item["max_stack"] - container[i]["slot"]["quantity"]
			var to_add = min(remaining, space)
			container[i]["slot"]["quantity"] += to_add
			remaining -= to_add
			container_updated.emit()
			slot_index = i
			print("Inserted item ", item["name"], " in container of ", owner.name, " with a count of ", item["quantity"], " at slot ",slot_index)
			if remaining <= 0:
				return true  # fully added
	# --- Pass 2: insert into empty slots ---
	for i in range(container.size()):
		# Respect tool_only slot restriction
		if container[i]["tool_only"] and not item.get("type", 0) == 2:
			continue
		if container[i]["slot"] == null and remaining > 0:
			var new_stack = item.duplicate(true)
			new_stack["quantity"] = min(remaining, item["max_stack"])
			container[i]["slot"] = new_stack
			remaining -= new_stack["quantity"]
			container_updated.emit()
			slot_index = i
			print("Inserted item ", item["name"], " in container of ", owner.name, " with a count of ", item["quantity"], " at slot ",slot_index)
			if remaining <= 0:
				return true
	# --- If we reach here, container is full ---
	return remaining <= 0

func initialize_container_slots():
	container.resize(slot_amount)
	print("Container initialized with ", slot_amount, " slots")
	for i in range(container.size()):
		# create a NEW dictionary each loop
		container[i] = {
			"slot": null,
			"tool_only": false
		}
		# assign tool_only if this index is in hotbar_slots
		if not hotbar_slots.is_empty() and i in hotbar_slots:
			container[i]["tool_only"] = true
			print("Slot ", i, " is now a hotbar slot")

func update_container():
	ContainerManager.update_container_ui()
	for i in range(container.size()):
		if container[i]["slot"] != null:
			if container[i]["slot"]["quantity"] < 1:
				container[i]["slot"] = null
			
