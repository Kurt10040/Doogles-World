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
		
		if (Global.hotbar_inventory[0] != null and Global.hotbar_inventory[1] != null) or Global.inventory.size() >= 2:
			print("theres stuff in ur hotbar too")
		else:
			print("not enough items in inventory")
