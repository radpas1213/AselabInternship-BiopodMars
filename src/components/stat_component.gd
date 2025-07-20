extends Node2D
class_name StatComponent

@export_category("General Stats")
@export var max_health: float = 20

@export_category("Player Specific Stats")
@export var max_hunger: float = 20
@export var max_stamina: float = 20

@export_category("Plant Specific Stats")
@export var max_watered: float = 20
@export var max_fertilized: float = 20

var current_health: float = 20
var current_hunger: float = 20
var current_stamina: float = 20
var current_watered: float = 20
var current_fertilized: float = 20

func clamp_stats() -> void:
	current_health = clampf(current_health, 0, 20)
	current_hunger = clampf(current_hunger, 0, 20)
	current_stamina = clampf(current_stamina, 0, 20)
	current_watered = clampf(current_watered, 0, 20)
	current_fertilized = clampf(current_fertilized, 0, 20)

func hurt(val: float) -> void:
	current_health -= val
	clamp_stats()
	
func heal(val: float) -> void:
	current_health += val
	clamp_stats()

func satiate(val: float) -> void:
	current_hunger -= val
	clamp_stats()

func water(val: float) -> void:
	current_watered += val
	clamp_stats()
	
func fertilize(val: float) -> void:
	current_fertilized += val
	clamp_stats()
