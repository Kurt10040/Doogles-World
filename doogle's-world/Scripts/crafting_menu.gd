extends Control

# Object references
@onready var grid_container: GridContainer = $GridContainer
@onready var hotbar_container: HBoxContainer = $"../../../InventoryHotbar/InventoryHotbar/HBoxContainer"

@export var grid_size:int = 4
var dragged_slot = null


# Called when the node enters the scene tree for the first time.
func _ready():
	grid_container.columns = grid_size
	Global.inventory_updated.connect(_on_inventory_update)
	_on_inventory_update()

# Callback function for whenever the inventory_update signal is called
func _on_inventory_update():
	clear_inventory_grid()
	
	# Assign items from player's inventory to the inventory slots UI
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		
		# Connect signals for inventory slot drag and drop
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		
		grid_container.add_child(slot)
		if item != null:
			slot.set_inventory_slot(Global.inventory.find(item))
			slot.set_item(item)
		else:
			slot.queue_free()

# Clear the inventory
func clear_inventory_grid():
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()

# When the player starts draggin an inventory slot
func _on_drag_start(slot_control:Control):
	dragged_slot = slot_control

# When the player drops the slot onto another slot
func _on_drag_end():
	var target = get_slot_under_mouse()
	print(target)
	
	# Drop the slot only if the target is a valid target
	if target["slot"] != null and dragged_slot != target["slot"]:
		if target["container"] == "inventory":
			drop_slot(dragged_slot, target["slot"], "crafting", "inventory")
		else:
			drop_slot(dragged_slot,target["slot"], "crafting", "hotbar")
	dragged_slot = null # clear the variable

# Get the slot that the mouse is hovering over
func get_slot_under_mouse()->Dictionary:
	var mouse_pos = get_global_mouse_position()
	
	# Loop through the crafting menu grid container to find the slot the mouse is hovering over
	for slot in grid_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"crafting"}
	
	# Loop through the hotbar slot container to find the slot the mouse is hovering over
	for slot in hotbar_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"hotbar"}
	
	# No slot was found
	return {"slot":null, "container":""}

# Get the index of the slot object relative to its parent
func get_slot_index(slot:Control, slot_source)->int:
	if slot_source == "hotbar":
		for i in range(hotbar_container.get_child_count()):
			if hotbar_container.get_child(i) == slot:
				return i
	elif slot_source == "inventory":
		for i in range(grid_container.get_child_count()):
			if grid_container.get_child(i) == slot:
				return i
	
	return -1

# Change slot state
func drop_slot(slot1:Control, slot2:Control, slot1_src:String, slot2_src:String):
	var slot1_index = get_slot_index(slot1, slot1_src)
	var slot2_index = get_slot_index(slot2, slot2_src)
	if slot1_index == -1 or slot2_index == -1:
		print("invalid slot found")
		return
	else:
		if Global.swap_inventory_items(slot1_index,slot2_index,slot1_src,slot2_src):
			_on_inventory_update()
