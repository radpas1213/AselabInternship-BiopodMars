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
@onready var hitbox: Area2D = $HitBox

func _ready() -> void:
	Global.player = self
	hitbox.connect("hit", Callable(self, "_on_hit"))
	add_to_group("player")   

func _physics_process(delta: float) -> void:
	movement.handle_movement(delta)
	move_and_slide()

func _process(delta: float) -> void:
	if inputs.move_input_dir:
		state_machine.changeState($StateMachineComponent/MovingState)
	else:
		state_machine.changeState($StateMachineComponent/IdleState)


func _on_hit(damage: float) -> void:
	stats.hurt(damage)
	print("HP Player:", stats.current_health)

	if stats.current_health <= 0:
		_die()


func take_damage(amount: float) -> void:
	_on_hit(amount)


func _die() -> void:
	print("💀 Player mati")
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
