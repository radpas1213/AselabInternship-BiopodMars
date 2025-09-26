extends StaticBody2D
class_name Plant

@onready var interaction: InteractionComponent = $InteractionComponent
@onready var stats: StatComponent = $StatComponent

@export var label_text: String

func _ready() -> void:
	interaction.interact = Callable(self, "interact")
	PlantManager.plants.push_front(self)
	
	# Start with water slightly randomized but still full
	stats.current_hydration -= randf_range(0, 5)

func interact() -> void:
	stats.hydrate(0.0065)
	print("Watering plant")

func _physics_process(_delta: float) -> void:
	stats.hydrate(-0.00015 * TimeManager.time_multiplier)
	if stats.current_hydration < 7.5:
		stats.heal(0.001)
	if stats.current_hydration > 7.5 and stats.current_hydration <= 20:
		stats.heal(0.001)
