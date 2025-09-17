extends Resource
class_name LootTable

@export var items: Array[LootEntry] = []

func roll_loot() -> Array[Dictionary]:
	var loot: Array[Dictionary] = []
	for entry in items:
		if entry.item == null:
			continue
		
		var quantity = randi_range(entry.min_quantity, entry.max_quantity)
		if quantity <= 0:
			continue
		
		for i in range(quantity):
			var durability = randf_range(entry.min_durability, entry.max_durability)
			loot.append({
				"item": entry.item,
				"durability": durability
			})
	return loot
