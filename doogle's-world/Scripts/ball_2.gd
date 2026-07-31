extends StaticBody3D

@onready var interactable: Area3D = $Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if interactable.is_interactable:
		interactable.is_interactable = false
		print("The player touched my other balls")
		self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
