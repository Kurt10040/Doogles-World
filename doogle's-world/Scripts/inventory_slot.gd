extends Control

# Object references
@onready var outer_border := $outer_border
@onready var qty_label := $outer_border/ItemQuantity

@onready var details_panel:ColorRect = $DetailsPanel
@onready var item_name:Label = $DetailsPanel/ItemName
@onready var item_type:Label = $DetailsPanel/ItemType
@onready var item_class:Label = $DetailsPanel/ItemClass
@onready var item_rarity:RichTextLabel = $DetailsPanel/ItemRarity2
@onready var item_mass:Label = $DetailsPanel/ItemMass
@onready var shiny_background:Panel = $DetailsPanel/ShinyBackground


@onready var slot_label: Label = $outer_border/SlotLabel

@onready var item_icon := $outer_border/ItemIcon
@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal drag_start(slot)
signal drag_end()

var item = null
var hotbar_slot:int = -1
var inventory_slot_index:int = -1

var can_drop = true

func _ready() -> void:
	audio_player.stream = load("res://Assets/Sounds/SFX/click2.ogg")
	audio_player.volume_db = -30
	
	outer_border.scale = Vector2.ONE

# set hotbar index
func set_hotbar_slot(new_index:int)->void:
	hotbar_slot = new_index

func set_inventory_slot(new_index:int)->void:
	inventory_slot_index = new_index

func get_inventory_slot_index()->int:
	return inventory_slot_index

# when the player hovers over the item slot
func _on_item_button_mouse_entered():
	audio_player.play()
	if item != null:
		details_panel.visible = true
		animation_player.play("new_animation")

# when the player stops hovering over the item slot
func _on_item_button_mouse_exited():
	details_panel.visible = false
	animation_player.stop()
	outer_border.scale = Vector2.ONE

# Reset the inventory slot to empty
func set_empty()->void:
	qty_label.text = ""
	slot_label.text = ""
	#self.visible = false
	
# Assign an item to the inventory slot and update the details panel
func set_item(new_item:Dictionary)->void:
	item = new_item
	qty_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_mass.text = str(item["mass"]) + "kg"
	item_type.text = str(Stats.ItemType.keys()[item["type"]]).lstrip("_")
	item_class.text = str(Stats.ItemClass.keys()[item["class"]]).lstrip("_")
	item_rarity.text = "[b][i]" + str(Stats.ItemRarity.keys()[item["rarity"]]).lstrip("_") + "[/i][/b]"
	
	item_rarity.add_theme_color_override("default_color", Global.rarity_colors[item["rarity"]])
	
	if item["shiny"] == true:
		shiny_background.visible = true
	else:
		shiny_background.visible = false
	
	slot_label.text = str(item["name"])

func _on_item_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and can_drop:
			if item != null:
				var drop = false
				if hotbar_slot != -1:
					drop = Global.remove_item(hotbar_slot,true)
				else:
					drop = Global.remove_item(inventory_slot_index,false)
					
				Global.drop_item(item)
				if drop:
					self.queue_free()
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if item != null:
				if event.is_pressed():
					outer_border.modulate = Color(1,1,0)
					drag_start.emit(self)
				else:
					outer_border.modulate = Color(1,1,1)
					drag_end.emit()
