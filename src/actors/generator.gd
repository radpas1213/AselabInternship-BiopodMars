extends StaticBody2D

enum RepairStates {
	REPAIRED,
	NEEDS_REPAIRS,
	BROKEN
}
var repair_state: RepairStates = RepairStates.BROKEN

@export var items_needed: Dictionary = {}

func  _ready() -> void:
	assign_items_needed_for_repair()

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_3):
		print(ContainerManager.check_for_items_for_repairs(items_needed))

func _physics_process(delta: float) -> void:
	$InteractionComponent.trigger_interaction = ContainerManager.is_player_holding_repair_tool()

func assign_items_needed_for_repair():
	if repair_state == RepairStates.BROKEN:
		items_needed = {
			"item_wiring_unit" = 5,
			"item_control_chip" = 3,
			"item_screw" = 6,
			"item_iron" = 3,
			"item_silicone" = 5
		}
	elif repair_state == RepairStates.NEEDS_REPAIRS:
		items_needed = {
			"item_wiring_unit" = 2,
			"item_control_chip" = 1,
			"item_screw" = 3,
			"item_iron" = 2,
			"item_silicone" = 2
		}
	else:
		items_needed = {}


func label_text() -> String:
	if not ContainerManager.is_player_holding_repair_tool():
		return "Repair tool needed to interact"
	else:
		if repair_state == RepairStates.REPAIRED:
			return ""
		elif repair_state == RepairStates.NEEDS_REPAIRS:
			return "Hold R to repair Generator"
		elif repair_state == RepairStates.BROKEN:
			return "Urgent care needed!!! \nHold R to repair broken Generator"
	return ""
