@tool
extends TextureProgressBar
class_name HealthBarComponent

@export var bar_color: Color = Color.WHITE:
	set(color):
		bar_color = color
		tint_progress = color
@export_range(0, 100, 0.05) var progress: float = 0:
	set(new_progress):
		progress = new_progress
		value = new_progress
@export var bar_colors: Dictionary
@export var health_icon: Sprite2D

func _process(delta: float) -> void:
	tint_progress = change_bar_color()
	if health_icon != null:
		health_icon.modulate = change_bar_color()
	value = progress
	bar_colors.sort()

func change_bar_color() -> Color:
	if not bar_colors.is_empty():
		for i in bar_colors:
			if progress < i:
				return bar_colors.get(i)
	return bar_color
