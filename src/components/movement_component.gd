extends Node2D
class_name MovementComponent

# Properties
@export var speed: float = 75

var direction: Vector2
var current_direction: int = 1
var direction_names: PackedStringArray = ["left", "down", "up", "right"]
var real_direction_names: PackedStringArray = ["right", "down", "up", "right"]

@export var input_comp: InputComponent

func handle_movement(delta: float) -> void:
	if InteractionManager.is_interacting:
		owner.velocity = Vector2(0, 0)
		return
	# Movement
	direction = input_comp.move_input_dir
	if direction:
		owner.velocity.x = lerpf(owner.velocity.x, direction.x * speed, 0.85) 
		owner.velocity.y = lerpf(owner.velocity.y, direction.y * speed, 0.85) 
	else:
		owner.velocity.x = lerpf(owner.velocity.x, 0, 0.35) 
		owner.velocity.y = lerpf(owner.velocity.y, 0, 0.35) 
	
	if direction.x < 0:
		current_direction = 0
	if direction.x > 0:
		current_direction = 3
	if direction.y < 0:
		current_direction = 2
	if direction.y > 0:
		current_direction = 1
