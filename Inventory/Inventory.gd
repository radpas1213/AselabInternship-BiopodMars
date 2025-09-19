extends Control

@onready var slots = $Panel/GridContainer.get_children()

func _ready():
	slots[0].set_item("Potion", 5)
	slots[1].set_item("Sword", 1)
