extends StaticBody2D
class_name Plant

@onready var interaction: InteractionComponent = $InteractionComponent
@onready var stats: StatComponent = $StatComponent

func _ready() -> void:
	interaction.interact = Callable(self, "interact")
	PlantManager.plants.push_front(self)

func interact() -> void:
	print("interacting with " + name, " with ID " + String.num(get_instance_id()))
	print(PlantManager.plants)
