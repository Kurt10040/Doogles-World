extends CSGMesh3D

@onready var interactable: Area3D = $Interactable

# Initialize the callback function to run when the object gets interacted with.
func _ready():
	interactable.interact = _on_interact
	
	var interactKeybind: InputEventKey = InputMap.action_get_events("interact")[0]
	interactable.interact_name = "[" + interactKeybind.as_text_physical_keycode() + "] to craft"
	
# This functions runs when the player interacts with the object
func _on_interact():
	if interactable.is_interactable:
		if Global.hotbar_inventory[0] != null and Global.hotbar_inventory[1] != null:
			#TransmutationSystem.combine()
			print("The player wants to craft...")
			#var item_a := Stats.new()
			#item_a.set_base_properties(Global.hotbar_inventory[0])
			#var item_b := Stats.new()
			#item_b.set_base_properties(Global.hotbar_inventory[1])
			var item_a:Stats = $"../../Items/Inventory_item3".stats
			var item_b:Stats = $"../../Items/Inventory_item5".stats
			item_a.init_current_properties()
			item_b.init_current_properties()
			
			var crafted:Stats = TransmutationSystem.combine(item_a,item_b,{})
			var crafted_dict = crafted.get_data_as_dict()
			print(crafted_dict)
		
