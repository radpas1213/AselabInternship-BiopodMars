@tool
extends Area2D
class_name InteractionComponent

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var collision_size: Vector2 = Vector2(12.0, 12.0):
	set(value):
		collision_size = value
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var highlight_size: Vector2 = Vector2(22.0, 22.0):
	set(value):
		highlight_size = value
		if Engine.is_editor_hint():
			_update_highlight()
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var highlight_offset: Vector2 = Vector2(0.0, 0.0):
	set(value):
		highlight_offset = value
		if Engine.is_editor_hint():
			_update_highlight()
## Time it takes for the interaction key to be held before triggering the interaction
@export_custom(PROPERTY_HINT_NONE, "suffix:seconds") var interaction_duration: float = 0.15
@export var trigger_interaction: bool = true
@export var use_repair_key: bool = false

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

func _ready() -> void:
	_update_col_rad()
	_update_highlight()

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
	col_shape.shape.set("size", collision_size)
	
func _update_highlight():
	$Highlight.size = highlight_size
	$Highlight.position = (-highlight_size / 2) + highlight_offset
