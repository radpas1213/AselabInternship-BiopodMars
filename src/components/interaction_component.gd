@tool
extends Area2D
class_name InteractionComponent

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var collision_size: float = 12.0:
	set(value):
		collision_size = value
		_update_col_rad()

var show_debug: bool = false
var interact: Callable = func():
	pass
var type: Node2D

func _ready() -> void:
	type = owner
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_col_rad()

func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)
	
func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
	
func _draw() -> void:
	if not Engine.is_editor_hint() \
	and type is Plant \
	and InteractionManager.active_areas.size() > 0 \
	and InteractionManager.active_areas.front() == self:
		draw_circle(InteractionManager.active_areas.front().position, 3, Color.RED, true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_col_rad()
	queue_redraw()

func _update_col_rad() -> void:
	if col_shape and col_shape.shape and col_shape.shape is RectangleShape2D:
		col_shape.shape.size.x = collision_size
		col_shape.shape.size.y = collision_size
	
