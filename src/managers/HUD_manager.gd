extends CanvasLayer

@onready var debug_label: Label = $debug
@onready var time_label : Label = $TimeLabel
var elapsed_time := 0.0

# Durasi satu hari dalam detik (15 menit = 900 detik)
const DAY_DURATION := 900.0

# Hari saat ini
var current_day := 1


func _process(delta: float) -> void:
	if debug_label != null:
		debug_label.text = "FPS: " + String.num(Engine.get_frames_per_second())
	if time_label != null:
		getTime(delta)

func getTime(delta):
	elapsed_time += delta
	
	# Hitung waktu saat ini dalam hari
	var time_in_day := fmod(elapsed_time, DAY_DURATION)
	var normalized_time := time_in_day / DAY_DURATION

	# Total menit dalam hari (0 - 1439)
	var total_minutes := int(normalized_time * 24 * 60)
	var hour := total_minutes / 60
	var minute := total_minutes % 60

	# Format 12-jam dengan AM/PM
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12
	var period := "AM" if hour < 12 else "PM"

	# Update teks label waktu
	time_label.text = "Day %d - %02d:%02d %s" % [current_day, hour12, minute, period] 

	# Periksa pergantian hari
	if elapsed_time >= current_day * DAY_DURATION:
		current_day += 1
