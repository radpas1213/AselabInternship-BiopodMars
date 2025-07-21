extends CanvasLayer

@onready var debug_label: Label = $debug

func _process(delta: float) -> void:
	
	if debug_label != null:
		debug_label.text = "FPS: " + String.num(Engine.get_frames_per_second())
