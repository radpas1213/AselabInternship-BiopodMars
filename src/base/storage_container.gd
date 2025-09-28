extends StaticBody2D
class_name StorageContainer

@onready var container: ContainerComponent = $ContainerComponent
@onready var interaction: InteractionComponent = $InteractionComponent
@onready var open_sound: AudioStreamPlayer2D = $opensond
@onready var close_sound: AudioStreamPlayer2D = $closeso

@export var label_text: String = "Storage Container"
@export var loot_table: LootTable

var already_opened := false

func _ready() -> void:
	interaction.interact = Callable(self, "interact")
	interaction.on_exit = Callable(self, "hide_ui")
	Global.storages.push_back(self)
	
func interact():
	if InteractionManager.active_areas.is_empty():
		return

	var target_container = InteractionManager.active_areas.front().owner.container

	# If inventory is closed, open it with the target container
	if not ContainerManager.inventory_opened:
		ContainerManager.show_container_ui(target_container)
		open_sound.play()
		interaction.interaction_duration = 0
		already_opened = true
		return
	
	# If inventory is already open
	if ContainerManager.currently_opened_container != target_container:
		# Switch to the new container without closing
		ContainerManager.show_container_ui(target_container)
		open_sound.play()
		interaction.interaction_duration = 0
		already_opened = true
	else:
		if ContainerManager.inventory_opened and \
		not ContainerManager.currently_opened_container_ui.visible:
			ContainerManager.show_container_ui(target_container)
			open_sound.play()
			interaction.interaction_duration = 0
		# Same container → close it
		else:
			ContainerManager.hide_container_ui()
			close_sound.play()
			interaction.interaction_duration = 0.075


func hide_ui():
	if InteractionManager.active_areas.is_empty():
		ContainerManager.hide_container_ui(true)
