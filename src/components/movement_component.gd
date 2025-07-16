extends Node2D
class_name MovementComponent

# Properties
@export var speed: float = 125

var direction: Vector2
var direction_names: PackedStringArray = ["left", "down", "up", " right"]

@export var input_comp: InputComponent

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _handle_movement(delta: float) -> void:
	# Movement
	direction = input_comp.input_dir
	if direction:
		owner.velocity = direction * speed
	else:
		owner.velocity = direction.move_toward(Vector2.ZERO, speed)
