#extends Node
#
## Total waktu yang sudah berlalu dalam detik
#var elapsed_time := 0.0
#
## Durasi satu hari dalam detik (15 menit = 900 detik)
#const DAY_DURATION := 900.0
#
## Hari saat ini
#var current_day := 1
#
#var time_text : String
#
#
#
##func _ready() -> void:
	### Cari TimeLabel di seluruh node anak
	##
	##
	##if time_label == null:
		##push_error("TimeLabel tidak ditemukan. Pastikan node TimeLabel ada di dalam scene.")
	##else:
		##print("TimeLabel ditemukan di path: ", time_label.get_path())
#
#func _process(delta: float) -> void:
	#if HudManager.time_label == null:
		#return # Jika tidak ada TimeLabel, keluar dari fungsi
#
	#elapsed_time += delta
	#
	## Hitung waktu saat ini dalam hari
	#var time_in_day := fmod(elapsed_time, DAY_DURATION)
	#var normalized_time := time_in_day / DAY_DURATION
#
	## Total menit dalam hari (0 - 1439)
	#var total_minutes := int(normalized_time * 24 * 60)
	#var hour := total_minutes / 60
	#var minute := total_minutes % 60
#
	## Format 12-jam dengan AM/PM
	#var hour12 := hour % 12
	#if hour12 == 0:
		#hour12 = 12
	#var period := "AM" if hour < 12 else "PM"
#
	## Update teks label waktu
	#time_text = "Day %d - %02d:%02d %s" % [current_day, hour12, minute, period]
#
	## Periksa pergantian hari
	#if elapsed_time >= current_day * DAY_DURATION:
		#current_day += 1
#
## Fungsi bantu untuk mencari TimeLabel secara rekursif
##func find_time_label() -> Label:
	##for child in get_tree().get_root().get_children():
		##var found := _find_label_recursive(child)
		##if found:
			##return found
	##return null
##
##func _find_label_recursive(node: Node) -> Label:
	##if node is Label and node.name == "TimeLabel":
		##return node
	##for child in node.get_children():
		##if child is Node:
			##var result := _find_label_recursive(child)
			##if result:
				##return result
	##return null
