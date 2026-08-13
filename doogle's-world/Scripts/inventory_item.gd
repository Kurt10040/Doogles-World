@tool
extends Node3D

@export var stats: Stats    # Reference to custom 'Stats' class for item properties

var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var object_mesh:MeshInstance3D = $Mesh
@onready var interactable = $Interactable


# Called when the node enters the scene tree for the first time.
func _ready():
	# Change the mesh of the item to the specified mesh in game
	if not Engine.is_editor_hint() and stats:
		var interactKeybind: InputEventKey = InputMap.action_get_events("interact")[0]
		interactable.interact_name = "[" + interactKeybind.as_text_physical_keycode() + "] to pick up " + stats.name
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
		print("The player picked up ", item["name"])
		if Global.player_node:
			Global.add_item(item)
			self.queue_free()

# Set item data from external source
func set_item_data(data):
	stats = Stats.new()
	stats.name =        data["name"]
	stats.type =        data["type"]
	stats.item_class =  data["class"]
	stats.rarity =      data["rarity"]
	stats.mass =        data["mass"]
	stats.is_shiny =    data["shiny"]
	stats.efficacy =    data["efficacy"]
	stats.enchantment = data["enchantment"]
	stats.icon =        data["icon"]
	stats.mesh =        data["mesh"]
	scene_path =        data["scene_path"]
	
	stats.base_heat =         data["base_heat"]
	stats.base_stability =    data["base_stability"]
	stats.base_volatility =   data["base_volatility"]
	stats.base_density =      data["base_density"]
	stats.base_conductivity = data["base_conductivity"]
	stats.base_purity =       data["base_purity"]
	stats.base_strength =     data["base_strength"]
	stats.base_acidity =      data["base_acidity"]
	stats.base_tags =         data["base_tags"]
