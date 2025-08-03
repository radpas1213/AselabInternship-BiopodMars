extends Node
class_name State

@export var state_name: String = ""

signal onStateEnter
signal onStateExit
signal onStateProcess
signal OnStatePhysicsProcess

# Tambah state ketika state terbuat di scene
func _ready() -> void:
	if get_parent() is StateMachineComponent:
		get_parent().addState(self)
		print("Adding state " + state_name, " to state list.")
