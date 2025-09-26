extends CanvasLayer
class_name HUD

@onready var item_label: Control = $UI/Item_Label
@onready var debug_label: Label = $debug
@onready var time_label : Label = $TimeLabel
@onready var day_screen := $DayTransitionScreen
@onready var day_label := $DayTransitionScreen/Label
@onready var time_overlay: ColorRect = $time_overlay
@onready var hotbar: Control = $UI/Inventories/Hotbar
@onready var moving_item: Control = $UI/MovingItem

func _init() -> void:
	Global.HUD = self
	
func _ready() -> void:
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
	
	moving_item.position = get_viewport().get_mouse_position()
	
	update_item_label()

func update_item_label():
	if item_label != null and item_label.visible:
		if InteractionManager.active_areas.is_empty():
			item_label.hide()
		else:
			var area_owner = InteractionManager.active_areas.front().owner
			match area_owner:
				_ when area_owner is Item:
					item_label.get_child(0).text = "Press E to pick up\n" + area_owner.item_resource.item_name
				_ when area_owner is StorageContainer:
					item_label.get_child(0).text = "Press E to open\n" + area_owner.label_text
				_ when area_owner is Plant:
					if item_label.get_child(0).text != area_owner.label_text:
						item_label.get_child(0).text = area_owner.label_text

func show_item_label(area: Area2D) -> void:
	item_label.show()
