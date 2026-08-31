extends Control

# Object references
@onready var grid_container: GridContainer = $GridContainer
@onready var slot_container: HBoxContainer = $Panel/SlotContainer
@onready var hotbar_container: HBoxContainer = $"../../../InventoryHotbar/InventoryHotbar/HBoxContainer"

@onready var item_preview: Control = $"../../ItemPreview"
@onready var preview_mesh: MeshInstance3D = $"../../ItemPreview/SubViewportContainer/SubViewport/Node3D/MeshInstance3D"


@onready var craft_button: Button = $CraftButton

@onready var result_name: RichTextLabel = $ResultStats/ResultName2
@onready var result_class: Label = $ResultStats/ResultClass
@onready var result_type: Label = $ResultStats/ResultType
@onready var result_weight: Label = $ResultStats/ResultWeight

@onready var animation_player: AnimationPlayer = $"../../../AnimationPlayer"
@onready var crafting_sounds: AudioStreamPlayer = $"../../../CraftingSounds"
const SHINY_SFX = preload("uid://dpeljsiepkwh4")


@export var grid_size:int = 4
var dragged_slot:Control = null

var item_1:Control = null
var item_2:Control = null

var crafting_result:Stats = null


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
	
	# Drop the slot only if the target is a valid target
	if target["slot"] != null and dragged_slot != target["slot"]:
		if target["container"] == "inventory":
			drop_slot(dragged_slot, target["slot"], "crafting", "inventory")
		elif target["container"] == "hotbar":
			drop_slot(dragged_slot,target["slot"], "crafting", "hotbar")
		else:
			set_crafting_slot(dragged_slot)
			print(target)
		
	if dragged_slot == target["slot"]:
		set_crafting_slot(dragged_slot)
		#print(target["slot"].item)
	
	dragged_slot = null # clear the variable

# Set the given slot as a slot to craft with
func set_crafting_slot(slot:Control):
	slot.can_drop = false
	if item_1 == null and slot != item_2:
		item_1 = slot
		slot.reparent(slot_container)
		return
	elif item_1 != null and item_2 == null and item_1 != dragged_slot:
		item_2 = slot
		slot.reparent(slot_container)
		return
	elif slot == item_1:
		item_1 = null
		slot.reparent(grid_container)
		return
	elif slot == item_2:
		item_2 = null
		slot.reparent(grid_container)
		return
	
	slot.can_drop = true
	return

# Get the slot that the mouse is hovering over
func get_slot_under_mouse()->Dictionary:
	var mouse_pos = get_global_mouse_position()
	
	# Loop through the crafting menu grid container to find the slot the mouse is hovering over
	for slot in grid_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"crafting"}
	
	for slot in slot_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		
		if slot_rect.has_point(mouse_pos):
			return {"slot":slot, "container":"crafting_slot"}
	
	
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


func _on_craft_button_pressed() -> void:
	# Debouce if there are no items to craft
	if item_1 == null and item_2 == null:
		return
	
	# Create the new item
	var item1_stats:Stats = Stats.new()
	var item2_stats:Stats = Stats.new()
	
	for key in item_1.item:
		if key in item1_stats:
			item1_stats.set(key, item_1.item[key])
		else:
			# Special cases for class, shiny and quantity because the names don't match
			if key == "class":
				item1_stats.set("item_class", item_1.item[key])
			elif key == "shiny":
				item1_stats.set("is_shiny", item_1.item[key])
			elif key not in ["quantity","scene_path"]:
				print("Unknown stat: ", key, " on item ", item_1.item["name"])
	item1_stats.init_current_properties()
	
	for key in item_2.item:
		if key in item2_stats:
			item2_stats.set(key, item_2.item[key])
		else:
			# Special cases for class, shiny and quantity because the names don't match
			if key == "class":
				item2_stats.set("item_class", item_2.item[key])
			elif key == "shiny":
				item2_stats.set("is_shiny", item_2.item[key])
			elif key not in ["quantity","scene_path"]:
				print("Unknown stat: ", key, " on item ", item_2.item["name"])
	item2_stats.init_current_properties()
	
	var new_item:Stats = TransmutationSystem.combine(item1_stats,item2_stats,{})
	new_item.init_current_properties()
	
	new_item.mesh = MeshGenerator.generate_item_mesh(new_item)
	
	print(new_item.get_data_as_dict())
	
	# Show the item preview
	preview_mesh.mesh = new_item.mesh
	
	animation_player.play("new_crafted")
	if new_item.is_shiny:
		crafting_sounds.stream = SHINY_SFX
		crafting_sounds.play()
	await animation_player.animation_finished
	
	# Update UI
	result_name.text = "[b][i]" + str(new_item.name) + "[/i][/b]"
	result_weight.text = str(new_item.mass) + "kg"
	result_type.text = str(Stats.ItemType.keys()[new_item.type]).lstrip("_")
	result_class.text = str(Stats.ItemClass.keys()[new_item.item_class]).lstrip("_")
	
	result_name.add_theme_color_override("default_color", Global.rarity_colors[new_item["rarity"]])
	
	#if new_item.is_shiny == true:
		#shiny_background.visible = true
	#else:
		#shiny_background.visible = false
		


# Close the item preview
func _on_close_pressed() -> void:
	animation_player.play("RESET")
