extends StaticBody2D
class_name Plant

@onready var interaction: InteractionComponent = $InteractionComponent
@onready var stats: StatComponent = $StatComponent

signal death

var random_stat: float = randf_range(0.8, 1.25)
var dying := false
var small := true
var dead := false
  
func _ready() -> void:
	interaction.on_interact_press = Callable(self, "press")
	interaction.on_interact_release = Callable(self, "release")
	interaction.interact = Callable(self, "interact")
	Global.plants.push_back(self)
	
	# Start with water slightly randomized but still full
	stats.current_hydration -= randf_range(0, 8)

func interact() -> void:
	stats.hydrate(5)
	if ContainerManager.get_item_in_hotbar()["resource"] == preload("res://data/items/item_watering_can.tres"):
		ContainerManager.get_item_in_hotbar()["durability"] -= 10
		ContainerManager.player_inventory_ui.linked_container.container_updated.emit()

func _physics_process(_delta: float) -> void:
	stats.hydrate(-0.0006 if small else -0.00045 * TimeManager.time_multiplier * random_stat)
	if stats.current_hydration < 7.5 or Global.start_hurting_actors:
		stats.heal(-0.001 if small else -0.00075 * random_stat)
	if stats.current_hydration > 7.5 and stats.current_hydration <= 20:
		stats.heal(0.001 if small else 0.00075 * random_stat)
	
	dying = stats.current_health <= 7.5
	if stats.current_health < 0.01:
		if dead != true:
			kill()
	
	if dying:
		$PlantSprite.modulate = Color(0.45, 0.45, 0.45, 1)
	else:
		$PlantSprite.modulate = Color.WHITE
	
	small = TimeManager.current_day < 3
	
	if small:
		if dying:
			$PlantSprite.frame = 1
		else:
			$PlantSprite.frame = 0
	else:
		if dying:
			$PlantSprite.frame = 3
		else:
			$PlantSprite.frame = 2
	
	interaction.trigger_interaction = ContainerManager.is_player_holding_water_can() and\
	ContainerManager.get_item_in_hotbar()["durability"] > 0

func plant_label() -> String:
	if ContainerManager.is_player_holding_water_can():
		if ContainerManager.get_item_in_hotbar()["durability"] < 1:
			return "Watering Can is empty"
		else:
			return "Hold E to water Plant"
	else:
		return "Watering Can needed to water Plant"
	return ""

func kill():
	dead = true
	death.emit()

func press():
	$AudioStreamPlayer2D.play()

func release():
	$AudioStreamPlayer2D.stop()
