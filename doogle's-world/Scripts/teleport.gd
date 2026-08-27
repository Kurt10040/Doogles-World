extends StaticBody3D

@onready var interactable: Area3D = $Interactable
@onready var whiteout: ColorRect = $"../../CanvasLayer/ColorRect"


# Sets the function to run when the object gets interacted with. This function runs once when the object is instatiated into the scene
func _ready() -> void:
	interactable.interact = _on_interact
	
# This functions runs when the player interacts with the object
func _on_interact():
	if interactable.is_interactable:
		interactable.is_interactable = false
		
		whiteout.mouse_filter = Control.MOUSE_FILTER_STOP
		var tween = create_tween()
		tween.tween_property(whiteout, "modulate", Color(0,0,0,1), 1.0)
		await tween.finished
		whiteout.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		Global.goto_scene("res://Scenes/homebase.tscn")
