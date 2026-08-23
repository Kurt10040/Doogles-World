extends Node3D

@onready var interactable: Area3D = $Interactable

# Initialize the callback function to run when the object gets interacted with.
func _ready() -> void:
	interactable.interact = _on_interact
	interactable.interact_name = "Craft"
	
# This functions runs when the player interacts with the object
func _on_interact() -> void:
	if interactable.is_interactable:
		print("The player wants to craft...")
		Global.player_node.find_child("CraftingMenu").visible = true
		Global.player_node.find_child("InventoryUI").visible = false
		
		if (Global.hotbar_inventory[0] != null and Global.hotbar_inventory[1] != null) or Global.inventory.size() >= 2:
			print("theres stuff in ur hotbar too")
			#var item_a := Stats.new()
			#item_a.set_identity(Global.hotbar_inventory[0])
			#item_a.set_base_properties(Global.hotbar_inventory[0])
			#var item_b := Stats.new()
			#item_b.set_identity(Global.hotbar_inventory[1])
			#item_b.set_base_properties(Global.hotbar_inventory[1])
			##var item_a:Stats = $Interactable/RigidBody3D2/Inventory_item5.stats
			##var item_b:Stats = $Interactable/RigidBody3D3/Inventory_item3.stats
			#item_a.init_current_properties()
			#item_b.init_current_properties()
			#
			#var crafted:Stats = TransmutationSystem.combine(item_a,item_b,{})
			#var crafted_dict:Dictionary = crafted.get_data_as_dict()
			#print(crafted_dict)
		else:
			print("not enough items in inventory")
