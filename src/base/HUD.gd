extends CanvasLayer
class_name HUD

@onready var item_label: Control = $UI/Item_Label
@onready var debug_label: Label = $debug
@onready var time_label : Label = $Clock/TimeLabel
@onready var day_screen := $DayTransitionScreen
@onready var day_label := $DayTransitionScreen/Label
@onready var time_overlay: ColorRect = $time_overlay
@onready var hotbar: Control = $UI/Inventories/Hotbar
@onready var moving_item: Control = $UI/MovingItem
@onready var items_needed_repair_hud: Control = $UI/ItemsNeededForRepair
@onready var notification_label: Label = $UI/NotificationLabel

var tween_finished := false

func _init() -> void:
	Global.HUD = self
	
func _ready() -> void:
	Global.HUD = self
	notification_label.hide()
	await get_tree().create_timer(30).timeout
	var tween = get_tree().create_tween()
	tween.tween_property($Tutorial, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(tween_fin)

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_0):
		show_notif_label("boo", true)

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
	if tween_finished:
		if $Tutorial != null:
			$Tutorial.visible = $PauseMenu.visible
	
	update_item_label()
	

func update_item_label():
	if item_label != null and item_label.visible:
		if InteractionManager.active_areas.is_empty():
			item_label.hide()
		else:
			var area_owner = InteractionManager.active_areas.front().owner
			match area_owner:
				_ when area_owner is Item:
					item_label.get_child(0).text = "Hold E to pick up\n" + area_owner.item_resource.item_name
				_ when area_owner is StorageContainer:
					item_label.get_child(0).text = "Hold E to open\n" + area_owner.label_text
				_ when area_owner is Plant:
					item_label.get_child(0).text = area_owner.plant_label()
				_ when area_owner.name == "Sink":
					item_label.get_child(0).text = area_owner.label_text()
				_ when area_owner.name == "Generator":
					item_label.get_child(0).text = area_owner.label_text()
				_:
					item_label.get_child(0).text = "Hold E to interact"

func show_item_label(area: Area2D) -> void:
	item_label.show()

func tween_fin():
	tween_finished = true

func show_notif_label(text: String, fade_out: bool = false):
	notification_label.show()
	notification_label.text = text
	if fade_out:
		notification_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		await get_tree().create_timer(1).timeout
		var notif_tween = get_tree().create_tween()
		notif_tween.tween_property(notification_label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.75)
		notif_tween.tween_callback(hide_notif_label)

func hide_notif_label():
	notification_label.hide()
	notification_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
