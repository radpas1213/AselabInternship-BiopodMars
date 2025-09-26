extends Node

var active_areas = []
var can_interact: bool = true
var interact_timer: Timer = null
var is_interacting: bool = false

# registers an interaction component to active_areas
func register_area(area: InteractionComponent):
	active_areas.push_back(area)

# unregisters an interaction component from active_areas
func unregister_area(area: InteractionComponent):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(_delta: float) -> void:
	# tells godot to sort the areas based on distance to the player
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)

func _sort_by_distance_to_player(area1: InteractionComponent, area2: InteractionComponent):
	var area1_to_plr = Global.player.global_position.distance_to(area1.global_position)
	var area2_to_plr = Global.player.global_position.distance_to(area2.global_position)
	
	if area1_to_plr == area2_to_plr:
		# tie-breaker → pick the one with the smaller instance_id
		return area1.get_instance_id() < area2.get_instance_id()
	
	return area1_to_plr < area2_to_plr

func _input(event: InputEvent) -> void:
	if active_areas.is_empty():
		return

	# Start interaction attempt
	if event.is_action_pressed("interact") and can_interact and not is_interacting:
		start_interaction()

	# Cancel interaction if released
	if event.is_action_released("interact") and is_interacting:
		reset_interaction()


func start_interaction() -> void:
	is_interacting = true
	can_interact = false
	var duration = active_areas.front().interaction_duration
	interact_timer = Timer.new()
	interact_timer.one_shot = true
	add_child(interact_timer)
	interact_timer.start(duration)

	# Use detached async block so we can cancel cleanly
	_run_interaction(duration)

func _run_interaction(duration: float) -> void:
	if duration != 0:
		await interact_timer.timeout

	# If canceled midway, do nothing
	if not is_interacting:
		return

	# Only interact if key still held
	if Input.is_action_pressed("interact") and active_areas.size() > 0:
		await active_areas.front().interact.call()

	reset_interaction()

func reset_interaction() -> void:
	is_interacting = false
	can_interact = true
	if interact_timer != null:
		interact_timer.stop()
		interact_timer.queue_free()
	interact_timer = null
