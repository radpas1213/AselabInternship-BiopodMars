extends Resource
class_name ItemData

@export_category("Item Properties")
## Name of item. Nama item.
@export var item_name:String = "Item"

@export_category("Visual Properties")
## Item texture
@export var texture: Texture2D
## Item texture size. Ukuran tekstur item
@export var texture_size: float = 0.5

func get_id() -> String:
	return "item_" + item_name.replace(" ", "_").to_lower()
