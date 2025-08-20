extends CanvasLayer

@onready var debug_label: Label = $debug
@onready var time_label : Label = $TimeLabel
@onready var day_screen := $DayTransitionScreen
@onready var day_label := $DayTransitionScreen/Label
@onready var time_overlay: ColorRect = $time_overlay

func _init() -> void:
	Global.HUD = self

func _process(delta: float) -> void:
	if debug_label != null:
		debug_label.text =  \
		"FPS: " + String.num(Engine.get_frames_per_second()) + "\n"
		#"State: " + Global.player.state_machine.current_state.state_name
	if time_label != null:
		time_label.text = TimeManager.time_text
	if day_label != null:
		day_label.text = TimeManager.day_text
	if day_screen:
		day_screen.visible = TimeManager.is_showing_day_screen
	if time_overlay != null:
		time_overlay.color = TimeManager.time_color
