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
	container_updated.connect(ContainerManager.update_container_ui)

func add_item(item: Dictionary):
	var remaining = item["quantity"]
	# Pass 1: fill existing stacks of same item
	for i in range(container.size()):
		if container[i]["slot"] != null and \
		container[i]["slot"]["id"] == item["id"] and \
		container[i]["slot"]["quantity"] < item["max_stack"]:
			# respect tool_only slot restriction
			var space = item["max_stack"] - container[i]["slot"]["quantity"]
			var to_add = min(remaining, space)
			container[i]["slot"]["quantity"] += to_add
			remaining -= to_add
			container_updated.emit()
			if remaining <= 0:
				return true  # fully added
	# Pass 2: insert into empty slots
	for i in range(container.size()):
		# respect tool_only slot restriction
		if container[i]["tool_only"] and not item.get("is_tool", true):
			continue
		if container[i]["slot"] == null and remaining > 0:
			var new_stack = item.duplicate(true)
			new_stack["quantity"] = min(remaining, item["max_stack"])
			container[i]["slot"] = new_stack
			remaining -= new_stack["quantity"]
			container_updated.emit()
			#print("item inserted at slot ", i)
			if remaining <= 0:
				return true
	# If we reach here, container is full and some items didn’t fit
	return false

func remove_item(item: Dictionary) -> void:
	container_updated.emit()
	container[container.find(item)]["slot"] = null

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
			print("Slot ",i," is now a hotbar slot")
