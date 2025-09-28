extends Resource
class_name LootEntry

@export var item: ItemData
## Chance for item to appear out of 20
@export_range(0.0, 20.0) var chance_to_appear: float = 5.0
@export var min_quantity: int = 1
@export var max_quantity: int = 1
@export_range(0.0, 20.0) var min_durability: float = 20.0
@export_range(0.0, 20.0) var max_durability: float = 20.0
