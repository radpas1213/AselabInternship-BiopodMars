extends Camera2D
class_name Camera

## Interpolation speed of camera zoom following the player, lower is slower, higher is faster
@export var cam_smoothness: float = 5
## Interpolation speed of the camera zoom, lower is slower, higher is faster
@export var cam_zoom_lerp_speed: float = 0.075
## Amount of scroll for camera zooming
@export var cam_zoom_scroll_amount: float = 0.25

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport

var zoom_lerp: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_lerp -= 0.2 * cam_zoom_scroll_amount
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_lerp += 0.2 * cam_zoom_scroll_amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	position = lerp(position, Global.player.position, delta * cam_smoothness)
	zoom_lerp = clampf(zoom_lerp, 0.65, 2)
	var target_zoom = lerpf(zoom.x, zoom_lerp, cam_zoom_lerp_speed)
	zoom = Vector2(target_zoom, target_zoom)
