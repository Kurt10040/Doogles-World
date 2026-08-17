extends Control


@onready var hotbar_container = $HBoxContainer
@onready var inventory_container:GridContainer = $"../../InventoryUI/InventoryFrame/inventory_UI/GridContainer"


var dragged_slot = null


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
		
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		
		hotbar_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_hotbar_container():
	for child in hotbar_container.get_children():
		hotbar_container.remove_child(child)
		child.queue_free()

# When the player starts draggin an inventory slot
func _on_drag_start(slot_control:Control):
	dragged_slot = slot_control

# When the player drops the slot onto another slot
func _on_drag_end():
	var target = get_slot_under_mouse()
	
	# Drop the slot only if the target is a valid target
	if target["slot"] != null and dragged_slot != target["slot"]:
		if target["container"] == "hotbar":
			drop_slot(dragged_slot, target["slot"], "hotbar", "hotbar")
		else:
			drop_slot(dragged_slot,target["slot"], "hotbar", "inventory")
	dragged_slot = null # clear the variable

# Get the slot that the mouse is hovering over
func get_slot_under_mouse()->Dictionary:
	var mouse_pos = get_global_mouse_position()
	
	for slot in hotbar_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"hotbar"}
	
	for slot in inventory_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"inventory"}
	
	return {"slot":null, "container":""}

func get_slot_index(slot:Control, slot_source)->int:
	if slot_source == "hotbar":
		for i in range(hotbar_container.get_child_count()):
			if hotbar_container.get_child(i) == slot:
				return i
	elif slot_source == "inventory":
		for i in range(inventory_container.get_child_count()):
			if inventory_container.get_child(i) == slot:
				return i
		
	
	return -1

func drop_slot(slot1:Control, slot2:Control, slot1_src:String, slot2_src:String):
	var slot1_index = get_slot_index(slot1, slot1_src)
	var slot2_index = get_slot_index(slot2, slot2_src)
	if slot1_index == -1 or slot2_index == -1:
		print("invalid slot found")
		return
	else:
		if Global.swap_inventory_items(slot1_index,slot2_index,slot1_src,slot2_src):
			print("Dropping slot items: ",slot1,slot2_index)
			_update_hotbar_ui()
