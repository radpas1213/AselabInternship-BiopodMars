extends CharacterBody2D
class_name Player

enum state {
	IDLE,
	WALKING,
	INTERACTING
}

@onready var movement_comp: MovementComponent = $MovementComponent
@onready var input_comp: InputComponent = $InputComponent

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	
	movement_comp.handle_movement(delta)
	
	move_and_slide()
