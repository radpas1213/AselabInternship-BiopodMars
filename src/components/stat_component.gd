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

var health: float = 20
var hunger: float = 20
var stamina: float = 20
var watered: float = 20
var fertilized: float = 20

func hurt(val: float) -> void:
	health -= val
	
func heal(val: float) -> void:
	health += val
