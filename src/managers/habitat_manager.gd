extends Node

var max_stat_value: float = 20
var initial_temperature: float = 23

var power: float = max_stat_value
var solar_power: float = max_stat_value
var temperature: float = initial_temperature
var oxygen_level: float = max_stat_value

enum RepairStates {
	DISREPAIR,
	SLIGHT_DISREPAIR,
	FINE,
	FINELY_REPAIRED,
	FULLY_REPAIRED
}

var repair_state: RepairStates = RepairStates.FULLY_REPAIRED

func initialize_habitat():
	power = max_stat_value
	solar_power = max_stat_value
	temperature = initial_temperature
	oxygen_level = max_stat_value
	repair_state = RepairStates.FULLY_REPAIRED

func _ready() -> void:
	initialize_habitat()
