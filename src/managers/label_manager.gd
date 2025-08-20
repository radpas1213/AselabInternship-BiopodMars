extends Control
class_name LabelManager

var label_scene: PackedScene = preload("res://actors/components/label.tscn")
var labels = []

func add_label(area: Area2D):	
	var label:= label_scene.instantiate()
	if not labels.has(label):
		labels.push_front(label)
	Global.HUD.find_child("Labels").add_child(label)
	if area.owner is Item:
		label.get_child(0).text = area.owner.item_resource.item_name
		#print("added label with text ", area.owner.item_resource.item_name, " as a child of ", label.get_parent())
	if area.owner is Plant:
		label.get_child(0).text = area.owner.label_text
		#print("added label with text ", area.owner.label_text)
	print(labels)
	#remove_label(area)

func remove_label(area: Area2D):
	if labels.size() > 0:
		labels.back().queue_free()
		labels.pop_back()
		#print("removed label from ", area.owner)
	print(labels)

func _process(delta: float) -> void:
	if InteractionManager.active_areas.size() > 0:
		var world_pos = (InteractionManager.active_areas.front().global_position - Vector2(20, 20))
		var screen_pos: Transform2D = Global.camera.get_canvas_transform().affine_inverse()
		#if active_label != null:
			#active_label.position = screen_pos
		
