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
@onready var sprite: AnimatedSprite2D = $Sprites/PlayerSprite
@onready var inventory: ContainerComponent = $ContainerComponent
@onready var held_item: Sprite2D = $Sprites/ItemSprite
var held_item_anim_offset = 0

var holding: bool = false

func _ready() -> void:
	Global.player = self
	stats.hunger_bar = Global.HUD.find_child("HungerBar")
	stats.health_bar = Global.HUD.find_child("HealthBar")
	ContainerManager.player_inventory = inventory

func _physics_process(delta: float) -> void:
	movement.handle_movement(delta)
	
	move_and_slide()

func _process(delta: float) -> void:
	if inputs.move_input_dir:
		state_machine.changeState($StateMachineComponent/MovingState)
	else:
		state_machine.changeState($StateMachineComponent/IdleState)
	
	_handle_sprites()
	_handle_held_item()

func _handle_sprites():
	var target_anim = target_animation()
	sprite.flip_h = movement.current_direction == 0
	if sprite.animation != target_anim:
		sprite.play(target_anim)

func _handle_held_item():
	held_item.visible = holding == true
	if sprite.animation.begins_with("walk"):
		held_item_anim_offset = 1 if sprite.frame == 0 or sprite.frame == 2 else 0
	else:
		held_item_anim_offset = 0
	var positions: PackedVector2Array = [
		Vector2(-10, -4),
		Vector2(0, -4),
		Vector2(0, -4),
		Vector2(10, -4)
	]
	held_item.position = positions[movement.current_direction] + Vector2(0, held_item_anim_offset)
	if movement.current_direction != 1:
		get_child(0).move_child(held_item, 0)
	else:
		get_child(0).move_child(held_item, 1)

func target_animation() -> String:
	if movement.direction:
		return "walk_" + movement.real_direction_names[movement.current_direction] + ("_holding" if holding else "")
	else:
		return "idle_" + movement.real_direction_names[movement.current_direction] + ("_holding" if holding else "")
