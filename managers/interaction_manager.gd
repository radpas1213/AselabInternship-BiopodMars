extends Node

var active_areas = []
var can_interact: bool = true

func register_area(area: InteractionComponent):
	active_areas.push_back(area)

func unregister_area(area: InteractionComponent):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
	
		
func _sort_by_distance_to_player(area1: InteractionComponent, area2: InteractionComponent):
	var area1_to_plr = Global.player.global_position.distance_to(area1.global_position)
	var area2_to_plr = Global.player.global_position.distance_to(area2.global_position)
	return area1_to_plr < area2_to_plr

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			
			await active_areas[0].interact.call()
			
			can_interact = true
