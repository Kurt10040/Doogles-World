extends Node


signal inventory_updated
var player_node: Node = null
var inventory = []


func _ready():
	inventory.resize(30)

func add_item(item):
	for i in range(inventory.size()):
		# check if the item already exists in the inventory and has the same type
		if inventory[i] != null  and inventory[i]["name"] == item["name"] and inventory[i]["type"] == item["type"] and inventory[i]["class"] == item["class"]:
			inventory[i]["quanity"] += item["quantity"]
			inventory_updated.emit()
			return true
		elif inventory[i] == null: # If there is no match but there is an empty slot in the inventory
			inventory[i] = item
			inventory_updated.emit()
			return true
		# Return false if inventory is full
		return false
	
func remove_item():
	inventory_updated.emit()
	
func increase_inventory_size():
	inventory_updated.emit()
	
func set_player_ref(plr):
	player_node = plr
