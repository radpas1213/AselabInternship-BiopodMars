extends CanvasLayer

@onready var debug_label: Label = $debug
@onready var time_label : Label = $TimeLabel

func _process(delta: float) -> void:
	if debug_label != null:
		debug_label.text = "FPS: " + String.num(Engine.get_frames_per_second())
	if time_label != null:
		time_label.text = TimeManager.time_text
