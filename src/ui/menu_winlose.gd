extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Win.visible = false
	$Lose.visible = false
	$Win/RetryButton.pressed.connect(retry)
	$Win/ExitButton.pressed.connect(exit)
	$Lose/RetryButton.pressed.connect(retry)
	show_screen(Global.win_game)

func show_screen(win: bool = true):
	Global.game_started = false
	if win:
		$Win.visible = true
	else:
		$Lose.visible = true

func retry():
		Global.game_started = true
		get_tree().change_scene_to_file("res://levels/main.tscn")

func exit():
	get_tree().quit()
