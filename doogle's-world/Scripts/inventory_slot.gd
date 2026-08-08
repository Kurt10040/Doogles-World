extends Control

# Object references
@onready var outer_border = $OuterBorder
@onready var details_panel = $DetailsPanel
@onready var qty_label = $InnerBorder/ItemQuantity
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_class = $DetailsPanel/ItemClass
@onready var item_rarity = $DetailsPanel/ItemRarity
@onready var item_mass = $DetailsPanel/ItemMass

var item = null
var hotbar_slot = -1


# set hotbar index
func set_hotbar_slot(new_index):
	hotbar_slot = new_index

# when the item slot is pressed
func _on_item_button_pressed():
	if item != null:
		print("["+str(hotbar_slot)+"]"+"You pressed a "+item["name"])

# when the player hovers over the item slot
func _on_item_button_mouse_entered():
	if item != null:
		details_panel.visible = true

# when the player stops hovering over the item slot
func _on_item_button_mouse_exited():
	details_panel.visible = false

# Reset the inventory slot to empty
func set_empty():
	qty_label.text = ""
	self.visible = false
	
# Assign an item to the inventory slot and update the details panel
func set_item(new_item):
	item = new_item
	qty_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(Stats.ItemType.keys()[item["type"]]).lstrip("_")
	item_class.text = str(Stats.ItemClass.keys()[item["class"]]).lstrip("_")
	item_rarity.text = str(Stats.ItemRarity.keys()[item["rarity"]]).lstrip("_")
	item_mass.text = str(item["mass"])
