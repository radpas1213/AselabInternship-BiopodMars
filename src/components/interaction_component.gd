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

func _init() -> void:
	type = owner
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_col_rad()

func _on_body_entered(body: Node2D) -> void:
	if not Engine.is_editor_hint():
		Global.HUD.show_item_label(self)
		InteractionManager.register_area(self)
	
func _on_body_exited(body: Node2D) -> void:
	if not Engine.is_editor_hint():
		InteractionManager.unregister_area(self)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_col_rad()

func _update_col_rad() -> void:
	if col_shape and col_shape.shape and col_shape.shape is RectangleShape2D:
		col_shape.shape.size.x = collision_size
		col_shape.shape.size.y = collision_size
	
