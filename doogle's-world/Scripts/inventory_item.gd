@tool
extends Node3D

@export var stats: Stats    # Reference to custom 'Stats' class for item properties

var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var object_mesh:MeshInstance3D = $Mesh
@onready var interactable = $Interactable

func _init() -> void:
	RenderingServer.set_debug_generate_wireframes(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	if stats.name == "Meshy":
		#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		stats.mesh = MeshGenerator.generate_item_mesh(stats)
		var collision_shape = self.get_parent_node_3d().find_child("CollisionShape3D")
		var convex:ConvexPolygonShape3D = stats.mesh.create_convex_shape()
		collision_shape.shape = convex
		collision_shape.transform = self.object_mesh.transform
		
		var interact_hitbox:CollisionShape3D = self.find_child("InteractRangeCol")
		interact_hitbox.scale =  Vector3(2,2,2)
	
	# Change the mesh of the item to the specified mesh in game
	if not Engine.is_editor_hint() and stats:
		interactable.interact_name = "pick up " + stats.name
		interactable.interact = on_interact
		object_mesh.mesh = stats.mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Change the mesh of the item to the specified mesh while in the editor
	if Engine.is_editor_hint() and stats:
		object_mesh.mesh = stats.mesh

# Function that runs whenever the player enters the range of an interactable object 
func on_interact():
	if interactable.is_interactable:    # Debounce
		interactable.is_interactable = false
		
		# Initialize item object with the specified properties (properties references from the Stats class object
		var item = {
			"scene_path": scene_path,
			"quantity": 1,
			"name": stats.name,
			"icon": stats.icon,
			"type": stats.type,
			"class": stats.item_class,
			"rarity": stats.rarity,
			"mass": stats.mass,
			"shiny": stats.is_shiny,
			"efficacy": stats.efficacy,
			"enchantment": stats.enchantment,
			"mesh": object_mesh.mesh,
			
			"base_heat": stats.base_heat,
			"base_stability": stats.base_stability,
			"base_volatility": stats.base_volatility,
			"base_density": stats.base_density,
			"base_conductivity": stats.base_conductivity,
			"base_purity": stats.base_purity,
			"base_strength": stats.base_strength,
			"base_acidity": stats.base_acidity,
			"base_tags": stats.base_tags
		}
		
		# Add the item to player inventory
		if Global.player_node:
			Global.add_item(item)
			self.get_parent().queue_free()

# Set item data from external source
func set_item_data(data):
	stats = Stats.new()
	
	for key in data:
		if key in stats:
			stats.set(key, data[key])
		else:
			# Special cases for class, shiny and quantity because the names don't match
			if key == "class":
				stats.set("item_class", data[key])
			elif key == "shiny":
				stats.set("is_shiny", data[key])
			elif key not in ["quantity","scene_path"]:
				print("Unknown stat: ", key, " on item ", data["name"])
