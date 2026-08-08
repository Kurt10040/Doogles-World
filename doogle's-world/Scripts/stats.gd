extends Resource
class_name Stats

# Item Rarities
enum ItemRarity {
	JUNK,
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	DIVINE,
	SECRET
}
# Item Classes
enum ItemClass {
	ORGANIC,
	ORE,
	RAW_MATERIAL,
	CRYSTAL,
	LIFE_FORCE,
	TOOL,
	CONTAINER,
	WEARABLE,
	TROPHY
}
# Item Types
enum ItemType {
	PLANT,
	METAL,
	ROCK,
	GAS,
	WOOD,
	LIQUID,
	MAGIC,
	CREATURE_DROPS
}

# Initialize editable stats about the item. These can be customised in the inspector or through a script.
@export_group("Stats")
@export var item_name: String
@export var item_type: ItemType
@export var item_class: ItemClass
@export var item_rarity:ItemRarity
@export var item_mass: float
@export var item_is_shiny: bool
@export var item_efficacy: int
@export var item_enchantment: String
@export var item_mesh: Mesh
@export var item_icon: Texture

# Initialize editable properties of the item. These can be customised in the inspector or through a script.
@export_group("Properties")
@export var base_heat: float
@export var base_stability: float
@export var base_volatility: float
@export var base_density: float
@export var base_conductivity: float
@export var base_purity: float
@export var base_strength: int
@export var base_acidity: int
