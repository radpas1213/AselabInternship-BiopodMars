extends CharacterBody2D

@onready var movement_comp: MovementComponent = $MovementComponent
@onready var input_comp: InputComponent = $InputComponent

func _physics_process(delta: float) -> void:
	
	movement_comp._handle_movement(delta)
	
	move_and_slide()
