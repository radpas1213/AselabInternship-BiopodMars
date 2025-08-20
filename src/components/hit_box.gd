extends Area2D

signal hit(damage: float)

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_area_entered(area):
	if area.has_method("get_damage"):
		emit_signal("hit", area.get_damage())

func _on_body_entered(body):
	if body.has_method("get_damage"):
		emit_signal("hit", body.get_damage())
