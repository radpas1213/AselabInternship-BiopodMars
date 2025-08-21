extends Area2D


@export var damage: float = 5
@export var speed: float = 100
@export var max_health: int = 100
@export var stop_distance: float = 20.0  
@export var attack_cooldown: float = 1.5 #nyerang berapa lama
@export var chase_duration: float = 2.0  #ngejar berapa lama


var health: int
var player: Node2D = null
var can_attack: bool = true
var player_in_attack_range: bool = false
var is_chasing: bool = false


@onready var detection_area: Area2D = $DetectionArea
@onready var attack_box: Area2D = $AttackBox
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var attack_timer: Timer = $AttackTimer
@onready var chase_timer: Timer = $ChaseTimer

func _ready():
	
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false
	
	
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	
	chase_timer.wait_time = chase_duration
	chase_timer.one_shot = true
	
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_box.body_entered.connect(_on_attack_box_body_entered)
	attack_box.body_exited.connect(_on_attack_box_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	chase_timer.timeout.connect(_on_chase_timer_timeout)

func _process(delta: float) -> void:
	if player != null and is_instance_valid(player) and is_chasing:
		var distance = global_position.distance_to(player.global_position)
		
		if distance > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			position += direction * speed * delta
		
		if player_in_attack_range and can_attack:
			_attack(player)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		health_bar.visible = true
		is_chasing = true
		chase_timer.start()
		print("Musuh ngejar berapa lama ", chase_duration, " seconds")

func _on_detection_area_body_exited(_body):
	pass

func _on_chase_timer_timeout():
	is_chasing = false
	player = null
	health_bar.visible = false
	player_in_attack_range = false
	print("Musuh Berhenti ngejar")

func _on_attack_box_body_entered(body):
	if body.is_in_group("player") and body == player and is_chasing:
		player_in_attack_range = true

func _on_attack_box_body_exited(body):
	if body == player:
		player_in_attack_range = false

func _attack(body):
	if not can_attack or not player_in_attack_range or not is_chasing:
		return
	
	print("Enemy attack player! -", damage, " HP")
	body.take_damage(damage)
	can_attack = false
	attack_timer.start()

func _on_attack_timer_timeout():
	can_attack = true

func take_damage(amount: int) -> void:
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()
