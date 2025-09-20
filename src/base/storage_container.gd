extends StaticBody2D
class_name StorageContainer

@onready var container: ContainerComponent = $ContainerComponent
@onready var interaction: InteractionComponent = $InteractionComponent

@export var label_text: String = "Storage Container"

func _ready() -> void:
	interaction.interact = Callable(self, "interact")
	interaction.on_exit = Callable(self, "hide_ui")
	interaction.on_enter = Callable(self, "show_ui")

func interact():
	if not ContainerManager.inventory_opened:
		ContainerManager.show_container_ui(container)
	else:
		ContainerManager.hide_container_ui()

func hide_ui():
	ContainerManager.currently_opened_container_ui.hide_ui()

func show_ui():
	if ContainerManager.inventory_opened:
		ContainerManager.currently_opened_container_ui.show_ui()
