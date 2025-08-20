extends Area2D

@export var damage: float = 5
@onready var attack_box: Area2D = $AttackBox

func _ready():
	# Connect sinyal ketika ada body masuk ke AttackBox
	attack_box.body_entered.connect(_on_attack_box_body_entered)

func _on_attack_box_body_entered(body):
	if body.is_in_group("player"):
		print("Player kena serang! -", damage, "HP")
		body.take_damage(damage)  # Player harus punya fungsi ini
