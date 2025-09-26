@tool
extends Button

@onready var button_text: Label = $Text

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var font_size: float = 12.0:
	set(new_size):
		font_size = new_size
		if Engine.is_editor_hint():
			button_text.add_theme_font_size_override("font_size", new_size)

var text_colors: Dictionary = {
	"normal" = Color(0.38, 0.82, 0.384),
	"hover" = Color(0.639, 0.894, 0.643),
	"pressed" = Color(0.914, 0.024, 0.024)
}
var held := false

func _ready() -> void:
	button_text.text = text
	button_text.add_theme_font_size_override("font_size", font_size)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		button_text.text = text


func _on_mouse_entered() -> void:
	if Input.is_action_pressed("mouse_left") and held:
		button_text.add_theme_color_override("font_color", text_colors["pressed"])
		button_text.position.y = 2
	else:
		button_text.add_theme_color_override("font_color", text_colors["hover"])

func _on_mouse_exited() -> void:
	button_text.add_theme_color_override("font_color", text_colors["normal"])
	button_text.position.y = 0

func _on_button_down() -> void:
	button_text.add_theme_color_override("font_color", text_colors["pressed"])
	button_text.position.y = 2
	held = true

func _on_button_up() -> void:
	button_text.add_theme_color_override("font_color", text_colors["normal"])
	button_text.position.y = 0
	held = false
