extends Resource
class_name ItemData

@export_category("Item Properties")
## Name of item. Nama item.
@export var item_name: String = "Item"
enum Type {
	Item,
	Resource,
	Tool,
	Energy,
	Scrap
}
@export var item_type: Type = 0
@export_range(1, 16, 1) var max_stack: int = 16

@export_category("Visual Properties")
## Item texture
@export var texture: Texture2D
## Item texture size. Ukuran tekstur item
@export var item_texture_size: float = 0.5
@export var inventory_texture_size: float = 0.5
