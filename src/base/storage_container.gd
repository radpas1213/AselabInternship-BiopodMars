extends StaticBody2D
class_name StorageContainer

@onready var container: ContainerComponent = $ContainerComponent
@onready var interaction: InteractionComponent = $InteractionComponent

@export var label_text: String = "Storage Container"

func _ready() -> void:
	interaction.interact = Callable(self, "interact")
	interaction.on_exit = Callable(self, "hide_ui")
	interaction.on_enter = Callable(self, "show_ui")

func _process(delta: float) -> void:
	if not InteractionManager.active_areas.is_empty():
		if InteractionManager.active_areas.front().owner is ContainerComponent and\
		 ContainerManager.inventory_opened:
			ContainerManager.show_container_ui(InteractionManager.active_areas.front().owner.container)

func interact():
	if not ContainerManager.inventory_opened:
		if not InteractionManager.active_areas.is_empty():
			ContainerManager.show_container_ui(InteractionManager.active_areas.front().owner.container)
	else:
		ContainerManager.hide_container_ui()

func hide_ui():
	if InteractionManager.active_areas.is_empty():
		ContainerManager.hide_container_ui(true)

func show_ui():
	if ContainerManager.inventory_opened:
		if not InteractionManager.active_areas.is_empty():
			ContainerManager.show_container_ui(InteractionManager.active_areas.front().owner.container)
