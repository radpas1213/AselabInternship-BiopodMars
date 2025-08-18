extends Control
class_name LabelManager

var label_scene: PackedScene = preload("res://actors/components/label.tscn")
var active_labels: Dictionary = {}
var active_target: Vector2

func add_label(item: Node2D):
	var label:= label_scene.instantiate()
	if not active_labels.has(label):
		active_labels.set(item, label)
	if item is Item:
		label.get_child(0).text = item.item_resource.item_name
		print("added label with text ", item.item_resource.item_name)
	else:
		if item.label_text != null:
			label.get_child(0).text = item.label_text

func remove_label(item: Node2D):
	if active_labels.has(item):
		active_labels.get(item).queue_free()
		active_labels.erase(item) 
		print("removed label from ", item)

func _process(delta: float) -> void:
	if InteractionManager.active_areas.size() > 0:
		active_target = InteractionManager.active_areas.front().position
