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
		"mesh": BoxMesh.new(),
		
		"base_heat": 36,
		"base_stability": .9,
		"base_volatility": .6,
		"base_density": 400,
		"base_conductivity": .89,
		"base_purity": .7,
		"base_strength": 5000,
		"base_acidity": 2,
		"base_tags": [""]
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
		"mesh": TorusMesh.new(),
		
		"base_heat": 37.2,
		"base_stability": .99,
		"base_volatility": .4,
		"base_density": 230,
		"base_conductivity": .24,
		"base_purity": .98,
		"base_strength": 2500,
		"base_acidity": 7,
		"base_tags": [""]
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
		"mesh": CylinderMesh.new(),
		
		"base_heat": 26,
		"base_stability": .4,
		"base_volatility": .2,
		"base_density": 67,
		"base_conductivity": .89,
		"base_purity": .46,
		"base_strength": 130,
		"base_acidity": 2,
		"base_tags": [""]
	},
]


func _ready():
	# Initialize inventory size
	inventory.resize(3)
	hotbar_inventory.resize(5)
	#TransmutationSystem.combine(Stats.new(),Stats.new(),{})
	

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
			if inventory[i] != null:
				var same_item = (
					inventory[i]["name"] == item["name"] and
					inventory[i]["type"] == item["type"] and
					inventory[i]["class"] == item["class"] and
					inventory[i]["mass"] == item["mass"]
					)
				
				if same_item:
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
	
func remove_item(item_index, is_from_hotbar:bool):
	if is_from_hotbar: # Remove the item from the hotbar
		if hotbar_inventory[item_index]:
			hotbar_inventory[item_index]["quantity"] -= 1
			
			# Delete the item slot if the quantity reaches 0
			if hotbar_inventory[item_index]["quantity"] <= 0:
				print("drop item "+str(item_index)+" from hotbar")
				hotbar_inventory[item_index] = null
				return true
			
			inventory_updated.emit()
			return false
	else: # Remove item from the main inventory
		if inventory[item_index]:
			inventory[item_index]["quantity"] -= 1
			
			if inventory[item_index]["quantity"] <= 0:
				print("drop item "+str(item_index)+" from inventory")
				inventory.remove_at(item_index)
				return true
			inventory_updated.emit()
			return false

# Adds a slot to the inventory table for new item
func increase_inventory_size(item):
	inventory.resize(inventory.size()+1)
	inventory[-1] = item
	inventory_updated.emit()

func drop_item(item_data):
	# Load and instance a new item node
	var item_scene = load(item_data["scene_path"])
	var item_instance: Node3D = item_scene.instantiate()
	
	# Set item instance data 
	item_instance.set_item_data(item_data)
	
	#get_tree().current_scene.add_child(item_instance)
	#item_instance.global_position = player_node.position + Vector3(0,4,0)
	
	var rigid_body := RigidBody3D.new()
	var collision_shape := CollisionShape3D.new()
	rigid_body.add_child(collision_shape)
	rigid_body.add_child(item_instance)
	
	item_instance.position = Vector3.ZERO
	item_instance.rotation = Vector3.ZERO
	
	# Reparenting
	get_tree().current_scene.add_child(rigid_body)
	
	# Collision detection and physics
	var item_mesh: Mesh = item_instance.object_mesh.mesh
	var convex:ConvexPolygonShape3D = item_mesh.create_convex_shape()
	collision_shape.shape = convex
	collision_shape.transform = item_instance.object_mesh.transform
	
	rigid_body.set_collision_layer_value(1,false)
	rigid_body.set_collision_layer_value(3,true)
	
	rigid_body.set_collision_mask_value(1,true)
	rigid_body.set_collision_mask_value(2,true)
	rigid_body.set_collision_mask_value(3,true)
	
	# Place the spawned item at the player
	rigid_body.global_position = player_node.position + Vector3(0,4,0)

func add_hotbar_item(item):
	for i in range(hotbar_inventory.size()):
		# check if the item already exists in the hotbar and has the same properties
		if hotbar_inventory[i] != null:
			# Variable that returns true if all of the properties match
			var same_item = (
					hotbar_inventory[i]["name"] == item["name"] and
					hotbar_inventory[i]["type"] == item["type"] and
					hotbar_inventory[i]["class"] == item["class"] and
					hotbar_inventory[i]["mass"] == item["mass"]
				)
			
			if same_item:
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
