extends Node2D
class_name MovementComponent

# Properties
@export var speed: float = 75

var direction: Vector2
var direction_names: PackedStringArray = ["left", "down", "up", " right"]

@export var input_comp: InputComponent

func handle_movement(delta: float) -> void:
	# Movement
	direction = input_comp.move_input_dir
	if direction:
		owner.velocity.x = lerpf(owner.velocity.x, direction.x * speed, 0.85) 
		owner.velocity.y = lerpf(owner.velocity.y, direction.y * speed, 0.85) 
	else:
		owner.velocity.x = lerpf(owner.velocity.x, 0, 0.35) 
		owner.velocity.y = lerpf(owner.velocity.y, 0, 0.35) 
