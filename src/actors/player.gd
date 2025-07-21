extends CharacterBody2D
class_name Player

enum state {
	IDLE,
	WALKING,
	INTERACTING
}

@onready var movement: MovementComponent = $MovementComponent
@onready var inputs: InputComponent = $InputComponent
@onready var stats: StatComponent = $StatComponent

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	
	movement.handle_movement(delta)
	
	move_and_slide()
