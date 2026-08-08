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
		print("The player wants to craft...")
