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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tint_progress = bar_color
	value = progress
