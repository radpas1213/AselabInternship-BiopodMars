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
		owner.velocity = direction * speed * 100 * delta
	else:
		owner.velocity = owner.velocity.move_toward(Vector2.ZERO, speed)
