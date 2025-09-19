extends Button

var item_name: String = ""
var item_count: int = 0

func set_item(name: String, count: int):
	item_name = name
	item_count = count
	text = "%s x%d" % [item_name, item_count]

func clear_item():
	item_name = ""
	item_count = 0
	text = ""
