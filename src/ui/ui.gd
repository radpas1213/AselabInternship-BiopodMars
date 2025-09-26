extends Control

func _ready() -> void:
	queue_redraw()
	print(find_child("PlayerInv", true).get_global_rect().get_center())

func _draw() -> void:
	#draw_rect(find_child("PlayerInv", true).get_global_rect(), Color.RED, true)
	draw_circle(find_child("PlayerInv", true).get_global_rect().get_center(), 10, Color.WHITE, true)
