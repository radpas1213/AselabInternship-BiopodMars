extends Node

#untuk warna vibes pagi siang sore malam
var time_color: Color = Color(0, 0, 0, 0) 

# ini buat ganti screen day
var is_showing_day_screen: bool = false
var day_screen_timer := 2.0  # durasi tampilan screen
var day_screen_elapsed := 0.0
var day_text : String

# Total waktu yang sudah berlalu dalam detik
var elapsed_time: float = 0.0
var multiplied_time: float = 0.0
var time_multiplier: float = 3.5

var starting_time: float = 340

# Durasi satu hari dalam detik (15 menit = 900 detik)
const DAY_DURATION: float = 900.0

signal day_changed
signal half_day

# Hari saat ini
var current_day: int = 1
var hours_passed: int = 0

var time_text: String

func _physics_process(delta: float) -> void:
	if Global.get_current_scene_name("MainLevel"):
		getTime(delta)
		
	# Tampilkan dan sembunyikan screen transisi hari
	if is_showing_day_screen:
		day_screen_elapsed += delta
		if day_screen_elapsed >= day_screen_timer:
			is_showing_day_screen = false
	

func getTime(delta):
	elapsed_time += delta
	multiplied_time = (elapsed_time * time_multiplier) + starting_time
	
	# Hitung waktu saat ini dalam hari
	var time_in_day := fmod(multiplied_time, DAY_DURATION)
	var normalized_time := time_in_day / DAY_DURATION

	hours_passed = (fmod((elapsed_time * time_multiplier), DAY_DURATION) / DAY_DURATION) * 24
	# Total menit dalam hari (0 - 1439)
	var total_minutes := int(normalized_time * 24 * 60)
	var hour := total_minutes / 60
	var real_minutes := total_minutes % 60
	var minute: float
	
	if real_minutes < 10:
		minute = 0
	else:
		minute = (String.num(real_minutes).left(1) + "0").to_float()
	
	if hour % 12 == 0:
		half_day.emit()
	
	# Format 12-jam dengan AM/PM
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12
	var period := "AM" if hour < 12 else "PM"

	# Update teks label waktu
	time_text = "Day %d - %02d:%02d %s" % [current_day, hour12, minute, period] 
	
	# Update warna latar berdasarkan jam
	update_background_color(hour)

	# Periksa pergantian hari
	if multiplied_time >= current_day * DAY_DURATION:
		current_day += 1
		show_day_transition(current_day)
		day_changed.emit()
		Global.repopulate_storage_containers()
		Global.HUD.show_notif_label("Earth has sent more resources. \nCheck the storage room.", true)
		if current_day == 5:
			Global.win_game = true
			get_tree().change_scene_to_file("res://menu/menu_winlose.tscn")
			Global.stop_light_flicker()

func show_day_transition(day: int) -> void:
	day_text = "Day %d" % day
	is_showing_day_screen = true
	day_screen_elapsed = 0.0
	
func update_background_color(hour: int) -> void:
	if hour >= 4 and hour < 6:
		time_color = Color(0.1, 0.1, 0.3, 0.3)  # Subuh
	elif hour >= 6 and hour < 11:
		time_color = Color(0.6, 0.8, 1.0, 0.2)  # Pagi
	elif hour >= 11 and hour < 15:
		time_color = Color(1.0, 1.0, 0.6, 0.2)  # Siang
	elif hour >= 15 and hour < 18:
		time_color = Color(1.0, 0.5, 0.2, 0.3)  # Sore
	else:
		time_color = Color(0.05, 0.05, 0.1, 0.4)  # Malam
