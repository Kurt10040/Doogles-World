extends Control

# Object references
@onready var outer_border := $outer_border

@onready var details_panel:ColorRect = $DetailsPanel
@onready var item_name:Label = $DetailsPanel/ItemName
@onready var item_type:Label = $DetailsPanel/ItemType
@onready var item_class:Label = $DetailsPanel/ItemClass

@onready var item_icon := $outer_border/ItemIcon

signal drag_start(slot)
signal drag_end()

var item = null
var slot_index:int = -1


func set_inventory_slot(new_index:int)->void:
	slot_index = new_index

func get_inventory_slot_index()->int:
	return slot_index

# when the player hovers over the item slot
func _on_item_button_mouse_entered():
	if item != null:
		details_panel.visible = true

# when the player stops hovering over the item slot
func _on_item_button_mouse_exited() -> void:
	details_panel.visible = false

func _on_item_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("pressed an equipment slot")



# Reset the inventory slot to empty
func set_empty()->void:
	pass
