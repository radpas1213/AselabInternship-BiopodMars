@tool
extends Area2D
class_name InteractionComponent

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var collision_size: Vector2 = Vector2(12.0, 12.0):
	set(value):
		collision_size = value
		_update_col_rad()
## Time it takes for the interaction key to be held before triggering the interaction
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var interaction_duration: float = 0.15

var show_debug: bool = false
var interact: Callable = func():
	pass
var on_enter: Callable = func():
	pass
var on_exit: Callable = func():
	pass
var type: Node2D

func _init() -> void:
	type = owner
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_col_rad()

func _on_body_entered(_body: Node2D) -> void:
	if not Engine.is_editor_hint():
		Global.HUD.show_item_label(self)
		InteractionManager.register_area(self)
		on_enter.call()
	
func _on_body_exited(_body: Node2D) -> void:
	if not Engine.is_editor_hint():
		InteractionManager.unregister_area(self)
		on_exit.call()
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_col_rad()
	else:
		$Highlight.visible = not InteractionManager.active_areas.is_empty() and InteractionManager.active_areas.front() == self

func _update_col_rad() -> void:
	if col_shape and col_shape.shape and col_shape.shape is RectangleShape2D:
		col_shape.shape.size.x = collision_size.x
		col_shape.shape.size.y = collision_size.y
	
