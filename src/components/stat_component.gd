extends Node2D
class_name StatComponent


@export_category("General Stats")
@export var max_health: float = 25
@export var health_bar: HealthBarComponent

@export_category("Player Specific Stats")
@export var max_hunger: float = 20
@export var hunger_bar: HealthBarComponent
@export var max_stamina: float = 20
@export var stamina_bar: HealthBarComponent
@export var max_sanity: float = 20
@export var sanity_bar: HealthBarComponent

@export_category("Plant Specific Stats")
@export var max_hydration: float = 20
@export var water_bar: HealthBarComponent
@export var max_fertilized: float = 20
@export var fertilizer_bar: HealthBarComponent
@export var max_light_level: float = 20

var current_health: float = max_health
var current_hunger: float = max_hunger
var current_stamina: float = max_stamina
var current_hydration: float = max_hydration
var current_fertilized: float = max_fertilized
var current_sanity: float = max_sanity
var current_light_level: float = max_light_level

func clamp_stats() -> void:
	current_health = clampf(current_health, 0, 20)
	current_hunger = clampf(current_hunger, 0, 20)
	current_stamina = clampf(current_stamina, 0, 20)
	current_hydration = clampf(current_hydration, 0, 20)
	current_fertilized = clampf(current_fertilized, 0, 20)
	current_sanity = clampf(current_sanity, 0, 20)

func heal(val: float) -> void:
	current_health += val * TimeManager.time_multiplier
	clamp_stats()

func satiate(val: float) -> void:
	current_hunger -= val * TimeManager.time_multiplier
	clamp_stats()

func hydrate(val: float) -> void:
	current_hydration += val * TimeManager.time_multiplier
	clamp_stats()
	
func fertilize(val: float) -> void:
	current_fertilized += val * TimeManager.time_multiplier
	clamp_stats()

func add_sanity(val: float) -> void:
	current_sanity += val * TimeManager.time_multiplier
	clamp_stats()
	
func hurt(val: float) -> void: 
	current_health -= val 
	clamp_stats()

func _process(_delta: float) -> void:
	if health_bar != null:
		health_bar.progress = current_health / max_health * 100
	if hunger_bar != null:
		hunger_bar.progress = current_hunger / max_hunger * 100
	if stamina_bar != null:
		stamina_bar.progress = current_stamina / max_stamina * 100
	if water_bar != null:
		water_bar.progress = current_hydration / max_hydration * 100
	if fertilizer_bar != null:
		fertilizer_bar.progress = current_fertilized / max_fertilized * 100
	if sanity_bar != null:
		sanity_bar.progress = current_sanity / max_sanity * 100
