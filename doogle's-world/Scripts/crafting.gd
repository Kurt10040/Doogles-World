extends Node3D

@onready var interactable: Area3D = $Interactable

# Initialize the callback function to run when the object gets interacted with.
func _ready() -> void:
	interactable.interact = _on_interact
	interactable.interact_name = "Craft"
	
# This functions runs when the player interacts with the crafting station
func _on_interact() -> void:
	if interactable.is_interactable:
		print("The player wants to craft...")
		Global.player_node.find_child("CraftingMenu").visible = true
		Global.player_node.find_child("InventoryUI").visible = false
