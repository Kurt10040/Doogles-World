extends Node


@onready var inventory_slot_scene = preload("res://Scenes/inventory_slot.tscn")

signal inventory_updated
var player_node: Node = null
var inventory = []
var hotbar_inventory = []

var spawnables = [
	{
		"scene_path": "res://Scenes/inventory_item.tscn",
		"quantity": 1,
		"name": "Shion",
		"icon": null,
		"type": 2,
		"class": 2,
		"rarity": 3,
		"mass": 2.700,
		"shiny": true,
		"efficacy": 4,
		"enchantment": "",
		"mesh": BoxMesh.new()
	},
	{
		"scene_path": "res://Scenes/inventory_item.tscn",
		"quantity": 2,
		"name": "Matther",
		"icon": null,
		"type": 5,
		"class": 1,
		"rarity": 5,
		"mass": 0.275,
		"shiny": false,
		"efficacy": 1,
		"enchantment": "",
		"mesh": TorusMesh.new()
	},
	{
		"scene_path": "res://Scenes/inventory_item.tscn",
		"quantity": 1,
		"name": "Chickenita",
		"icon": null,
		"type": 7,
		"class": 1,
		"rarity": 6,
		"mass": 0.300,
		"shiny": true,
		"efficacy": 7,
		"enchantment": "Toxic",
		"mesh": CylinderMesh.new()
	},
]


func _ready():
	# Initialize inventory size
	inventory.resize(3)
	hotbar_inventory.resize(5)

# Add a new item to the inventory
func add_item(item, to_hotbar = true):
	var added_to_hotbar = false
	
	# Add the item to the hotbar 
	if to_hotbar:
		added_to_hotbar = add_hotbar_item(item)
		inventory_updated.emit()
	
	# Add item into inventory if hotbar is full or to_hotbar is false
	if not added_to_hotbar:
		# Loop through each inventory slot
		for i in range(inventory.size()):
			# check if the item already exists in the inventory and has the same properties
			if inventory[i] != null  and inventory[i]["name"] == item["name"] and inventory[i]["type"] == item["type"] and inventory[i]["class"] == item["class"] and inventory[i]["mass"] == item["mass"]:
				inventory[i]["quantity"] += item["quantity"]
				inventory_updated.emit()
				return true
			elif inventory[i] == null: # If there is no match but there is an empty slot in the inventory
				inventory[i] = item
				inventory_updated.emit()
				return true
		
		# Add an inventory slot for the new item
		increase_inventory_size(item)
		return true
	
func remove_item():
	inventory_updated.emit()

# Adds a slot to the inventory table for new item
func increase_inventory_size(item):
	inventory.resize(inventory.size()+1)
	inventory[-1] = item
	inventory_updated.emit()

func drop_item(item_data):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)

func add_hotbar_item(item):
	for i in range(hotbar_inventory.size()):
		# check if the item already exists in the hotbar and has the same properties
		if hotbar_inventory[i] != null  and hotbar_inventory[i]["name"] == item["name"] and hotbar_inventory[i]["type"] == item["type"] and hotbar_inventory[i]["class"] == item["class"] and hotbar_inventory[i]["mass"] == item["mass"]:
			hotbar_inventory[i]["quantity"] += item["quantity"]
			return true
		elif hotbar_inventory[i] == null: # If there is no match but there is an empty slot in the hotbar
			hotbar_inventory[i] = item
			return true
	# If the hotbar is full
	return false

# Set a global reference to the player scene/object
func set_player_ref(plr):
	player_node = plr
