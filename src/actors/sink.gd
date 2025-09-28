extends Node2D

func _ready() -> void:
	$InteractionComponent.on_interact_press = Callable(self, "press")
	$InteractionComponent.on_interact_release = Callable(self, "release")
	$InteractionComponent.interact = Callable(self, "interact")

func _physics_process(delta: float) -> void:
	$InteractionComponent.trigger_interaction = ContainerManager.is_player_holding_water_can() and not Global.hostile_habitat

func label_text() -> String:
	if ContainerManager.is_player_holding_water_can():
		return "Hold E to fill up Watering Can"
	else:
		return "Watering Can needed to interact"
	return ""

func interact():
	if ContainerManager.get_item_in_hotbar()["resource"] == preload("res://data/items/item_watering_can.tres"):
		ContainerManager.get_item_in_hotbar()["durability"] = 20
		ContainerManager.player_inventory_ui.linked_container.container_updated.emit()

func press():
	$sound_fill.play()

func release():
	$sound_fill.stop()
