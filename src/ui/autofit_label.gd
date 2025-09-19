@tool
extends Label
class_name AutofitLabel

@export var scroll_speed: float = 50.0       # pixels per second
@export var edge_pause: float = 1.0          # seconds to pause at each edge

var text_width: float = 0.0
var offset_x: float = 0.0
var moving_left := true
var pause_timer := 0.0
var scrolling := false

func _ready() -> void:
	clip_text = true
	_update_text_metrics()
	queue_redraw()
	
func _set(name, value):
	match name:
		"text":
			text = value
			_update_text_metrics()
			queue_redraw()

func _process(delta: float) -> void:
	if not scrolling:
		return

	if pause_timer > 0.0:
		pause_timer -= delta
		return

	var move_amount = scroll_speed * delta * (-1 if moving_left else 1)
	offset_x += move_amount

	# Left edge reached
	if offset_x <= -(text_width - size.x):
		offset_x = -(text_width - size.x)
		moving_left = false
		pause_timer = edge_pause

	# Right edge reached
	elif offset_x >= 0.0:
		offset_x = 0.0
		moving_left = true
		pause_timer = edge_pause

	queue_redraw()

func _draw() -> void:
	if text.is_empty():
		return
	if not label_settings or not label_settings.font:
		return

	var font := label_settings.font
	var font_size := label_settings.font_size
	var base_pos := Vector2(offset_x, font_size)

	# If text fits → no scroll
	if not scrolling:
		base_pos.x = 0
	
	# 1. Shadow
	if label_settings.shadow_color.a > 0:
		var shadow_pos := base_pos + label_settings.shadow_offset
		font.draw_string(get_canvas_item(), shadow_pos, text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_settings.shadow_color)
		font.draw_string_outline(get_canvas_item(), shadow_pos, text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,label_settings.shadow_size, label_settings.shadow_color)

	# 2. Main text
	font.draw_string(get_canvas_item(), base_pos, text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_settings.font_color)
	
func _update_text_metrics() -> void:
	if not label_settings or not label_settings.font:
		return
	text_width = label_settings.font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_settings.font_size
	).x
	scrolling = text_width > size.x
