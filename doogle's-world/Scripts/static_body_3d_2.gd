extends StaticBody3D

@onready var interactable: Area3D = $Interactable


# Sets the function to run when the object gets interacted with. This function runs once when the object is instatiated into the scene
func _ready() -> void:
	interactable.interact = _on_interact
	
# This functions runs when the player interacts with the object
func _on_interact():
	if interactable.is_interactable:
		interactable.is_interactable = false
		print("The player touched my balls")
		self.queue_free()
