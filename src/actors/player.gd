extends CharacterBody2D
class_name Player

enum state {
	IDLE,
	WALKING,
	INTERACTING
}

@onready var state_machine: StateMachineComponent = $StateMachineComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var inputs: InputComponent = $InputComponent
@onready var stats: StatComponent = $StatComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Global.player = self
	stats.hunger_bar = Global.HUD.find_child("HungerBar")
	stats.health_bar = Global.HUD.find_child("HealthBar")

func _physics_process(delta: float) -> void:
	
	movement.handle_movement(delta)
	
	move_and_slide()

func _process(delta: float) -> void:
	if inputs.move_input_dir:
		state_machine.changeState($StateMachineComponent/MovingState)
	else:
		state_machine.changeState($StateMachineComponent/IdleState)
	
	_handle_sprites()

func _handle_sprites():
	if movement.direction:
		var target_anim = "walk_" + movement.real_direction_names[movement.current_direction]
		sprite.flip_h = movement.current_direction == 0
		if sprite.animation != target_anim:
			sprite.play(target_anim)
	else:
		var target_anim = "idle_" + movement.real_direction_names[movement.current_direction]
		sprite.flip_h = movement.current_direction == 0
		if sprite.animation != target_anim:
			sprite.play(target_anim)
