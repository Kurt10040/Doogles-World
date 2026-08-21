extends Node


@onready var inventory_slot_scene = preload("res://Scenes/inventory_slot.tscn")

var current_scene = null

signal inventory_updated
var player_node: Node = null
var inventory = []
var hotbar_inventory = []
var equipment_inventory = []

var hotbar_maxsize = 5

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


func _ready()->void:
	var root = get_tree().root
	current_scene = root.get_child(-1)
	
	# Initialize inventory size
	inventory.resize(0)
	hotbar_inventory.resize(hotbar_maxsize)
	equipment_inventory.resize(3)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

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
	
func remove_item(item_index, is_from_hotbar):
	if inventory.size() == 0:
		print("Nothing in inventory")
		
	if is_from_hotbar: # Remove the item from the hotbar
		if hotbar_inventory[item_index]:
			hotbar_inventory[item_index]["quantity"] -= 1
			
			# Delete the item slot if the quantity reaches 0
			if hotbar_inventory[item_index]["quantity"] <= 0:
				hotbar_inventory[item_index] = null
				inventory_updated.emit()
				return true
			
			inventory_updated.emit()
			return false
	else: # Remove item from the main inventory	
		if inventory[item_index]:
			inventory[item_index]["quantity"] -= 1
			
			if inventory[item_index]["quantity"] <= 0:
				inventory.remove_at(item_index)
				inventory_updated.emit()
				return true
			inventory_updated.emit()
			return false

# Adds a slot to the inventory table for new item
func increase_inventory_size(item):
	inventory.resize(inventory.size()+1)
	inventory[-1] = item
	inventory_updated.emit()

# Drop an item from the player inventory
func drop_item(item_data):
	# Load and instance a new item node
	var item_scene := load(item_data["scene_path"])
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

# Add an item into the player's hotbar
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

# Swap inventory items
func swap_inventory_items(index1, index2, source_container:String, target_container:String):
	if "hotbar" in source_container:
		source_container = "hotbar_inventory"
	if "hotbar" in target_container:
		target_container = "hotbar_inventory"
		
	if self.get(source_container) == null:
		push_warning("no source slot")
		return false
	
	if index1 < 0 or index1 > self.get(source_container).size() or index2 < 0 or index2 > self.get(target_container).size():
		push_warning("target index out of bounds")
		return false
	
	# Check if the player moved a slot from the inventory to the hotbar (and vice verse) or not
	if source_container != target_container:
		print("Moved slot "+str(index1)+" of "+source_container+" to slot "+str(index2)+" of "+target_container)
		if source_container == "inventory":
			var temp = inventory[index1]
			inventory[index1] = hotbar_inventory[index2]
			hotbar_inventory[index2] = temp
			inventory_updated.emit()
			return true
		else:
			var temp = hotbar_inventory[index1]
			hotbar_inventory[index1] = inventory[index2]
			inventory[index2] = temp
			inventory_updated.emit()
			return true
			
	else:
		# Swap items within inventory
		if source_container == "inventory":
			var temp = inventory[index1]
			inventory[index1] = inventory[index2]
			inventory[index2] = temp
			inventory_updated.emit()
			return true
		else:
		# Swap items within hotbar
			var temp = hotbar_inventory[index1]
			hotbar_inventory[index1] = hotbar_inventory[index2]
			hotbar_inventory[index2] = temp
			inventory_updated.emit()
			return true
			


# Set a global reference to the player scene/object
func set_player_ref(plr) -> void:
	player_node = plr
