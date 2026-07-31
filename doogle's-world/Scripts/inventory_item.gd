@tool
extends Node3D

@export var stats: Stats

var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var object_mesh = $Mesh
@onready var interactable = $Interactable

var player_in_range = false


# Called when the node enters the scene tree for the first time.
func _ready():
	interactable.interact = on_interact
	# Change the mesh of the item to the specified mesh in game
	if not Engine.is_editor_hint():
		object_mesh.mesh = stats.item_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Change the mesh of the item to the specified mesh while in the editor
	if Engine.is_editor_hint() and stats:
		object_mesh.mesh = stats.item_mesh

func on_interact():
	if interactable.is_interactable:
		interactable.is_interactable = false
		
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
		
		print("The player picked up this item ", item)
		if Global.player_node:
			Global.add_item(item)
			self.queue_free()
