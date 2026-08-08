extends Control

@onready var grid_container: GridContainer = $GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.inventory_updated.connect(_on_inventory_update)
	_on_inventory_update()

# Callback function for whenever the inventory_update signal is called
func _on_inventory_update():
	clear_inventory_grid()
	
	# Assign items from player's inventory to the inventory slots UI
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

# Clear the inventory
func clear_inventory_grid():
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
