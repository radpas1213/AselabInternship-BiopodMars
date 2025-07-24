extends Node

# ini buat ganti screen day
var is_showing_day_screen: bool = false
var day_screen_timer := 2.0  # durasi tampilan screen
var day_screen_elapsed := 0.0
var day_text : String

# Total waktu yang sudah berlalu dalam detik
var elapsed_time: float = 0.0
var multiplied_time: float = 0.0
var time_multiplier: float = 5.0

var starting_time: float = 340

# Durasi satu hari dalam detik (15 menit = 900 detik)
const DAY_DURATION: float = 900.0

# Hari saat ini
var current_day: int = 1

var time_text: String

func _physics_process(delta: float) -> void:
	if SceneManager.current_scene != null and \
	SceneManager.current_scene.scene_type == "Level" and \
	SceneManager.current_scene.current_level == "Test Level":
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

	# Total menit dalam hari (0 - 1439)
	var total_minutes := int(normalized_time * 24 * 60)
	var hour := total_minutes / 60
	var real_minutes := total_minutes % 60
	var minute: float
	
	if real_minutes < 10:
		minute = 0
	else:
		minute = (String.num(real_minutes).left(1) + "0").to_float()
	
	# Format 12-jam dengan AM/PM
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12
	var period := "AM" if hour < 12 else "PM"

	# Update teks label waktu
	time_text = "Day %d - %02d:%02d %s" % [current_day, hour12, minute, period] 

	# Periksa pergantian hari
	if multiplied_time >= current_day * DAY_DURATION:
		current_day += 1
		show_day_transition(current_day)

func show_day_transition(day: int) -> void:
	day_text = "Day %d" % day
	is_showing_day_screen = true
	day_screen_elapsed = 0.0
