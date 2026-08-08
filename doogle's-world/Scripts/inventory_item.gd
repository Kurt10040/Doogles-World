@tool
extends Node3D

@export var stats: Stats    # Reference to custom 'Stats' class for item properties

var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var object_mesh = $Mesh
@onready var interactable = $Interactable


# Called when the node enters the scene tree for the first time.
func _ready():
	# Change the mesh of the item to the specified mesh in game
	if not Engine.is_editor_hint() and stats:
		var interactKeybind: InputEventKey = InputMap.action_get_events("interact")[0]
		interactable.interact_name = "[" + interactKeybind.as_text_physical_keycode() + "] to pick up " + stats.item_name
		interactable.interact = on_interact
		object_mesh.mesh = stats.item_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Change the mesh of the item to the specified mesh while in the editor
	if Engine.is_editor_hint() and stats:
		object_mesh.mesh = stats.item_mesh

# Function that runs whenever the player enters the range of an interactable object 
func on_interact():
	if interactable.is_interactable:    # Debounce
		interactable.is_interactable = false
		
		# Initialize item object with the specified properties (properties references from the Stats class object
		var item = {
			"scene_path": scene_path,
			"quantity": 1,
			"name": stats.item_name,
			"icon": stats.item_icon,
			"type": stats.item_type,
			"class": stats.item_class,
			"rarity": stats.item_rarity,
			"mass": stats.item_mass,
			"shiny": stats.item_is_shiny,
			"efficacy": stats.item_efficacy,
			"enchantment": stats.item_enchantment,
		}
		
		# Add the item to player inventory
		print("The player picked up ", item["name"])
		if Global.player_node:
			Global.add_item(item)
			self.queue_free()

# Set item data from external source
func set_item_data(data):
	stats = Stats.new()
	stats.item_name = data["name"]
	stats.item_type = data["type"]
	stats.item_class = data["class"]
	stats.item_rarity = data["rarity"]
	stats.item_mass = data["mass"]
	stats.item_is_shiny = data["shiny"]
	stats.item_efficacy = data["efficacy"]
	stats.item_enchantment = data["enchantment"]
	stats.item_mesh = data["mesh"]
	stats.item_icon = data["icon"]
	scene_path = data["scene_path"]
