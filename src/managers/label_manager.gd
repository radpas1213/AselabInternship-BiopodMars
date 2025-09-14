extends Control
class_name LabelManager

func add_label(area: Area2D):
	
	if not InteractionManager.active_areas.has(area):
		print("label shown")
		Global.HUD.item_label.show()
		if area.owner is Item:
			Global.HUD.item_label.get_child(0).text = area.owner.item_resource.item_name
		if area.owner is Plant:
			Global.HUD.item_label.get_child(0).text = area.owner.label_text

func _process(delta: float) -> void:
	
	if not InteractionManager.active_areas.is_empty():
		var area_owner = InteractionManager.active_areas.front().owner
		if area_owner is Item:
			Global.HUD.item_label.get_child(0).text = area_owner.item_resource.item_name
		if area_owner is Plant:
			Global.HUD.item_label.get_child(0).text = area_owner.label_text
	
	if InteractionManager.active_areas.is_empty() and Global.HUD.item_label.visible:
		Global.HUD.item_label.hide()
		print("label hidden")
