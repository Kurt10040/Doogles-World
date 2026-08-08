extends Control


@onready var hotbar_container = $HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.inventory_updated.connect(_update_hotbar_ui)
	_update_hotbar_ui()

func _update_hotbar_ui():
	clear_hotbar_container()
	
	# Assign items from player's inventory to the inventory slots UI
	for i in range(Global.hotbar_inventory.size()):
		var item = Global.hotbar_inventory[i]
		var slot = Global.inventory_slot_scene.instantiate()
		slot.set_hotbar_slot(i)
		hotbar_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_hotbar_container():
	for child in hotbar_container.get_children():
		hotbar_container.remove_child(child)
		child.queue_free()
