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
enum MaterialProperties {
	SHINY,
	
}

# Initialize editable stats about the item. These can be customised in the inspector or through a script.
@export_group("Identity")
@export var name: String
@export var type: ItemType
@export var item_class: ItemClass
@export var rarity:ItemRarity

@export var mass: float
@export var is_shiny: bool
@export var efficacy: int
@export var enchantment: String

@export var mesh: Mesh
@export var icon: Texture

# Initialize editable properties of the item. These can be customised in the inspector or through a script.
@export_group("Base Properties")
@export var base_heat: float
@export var base_stability: float
@export var base_volatility: float
@export var base_density: float
@export var base_conductivity: float
@export var base_purity: float
@export var base_strength: int
@export var base_acidity: int
@export var base_tags: Array

var heat: float
var stability: float
var volatility: float
var density: float
var conductivity: float
var purity: float
var strength: int
var acidity: int
var tags: Array

func set_identity(data:Dictionary) -> void:
	name =        data["name"]
	type =        data["type"]
	item_class =  data["class"]
	rarity =      data["rarity"]
	
	mass =        data["mass"]
	is_shiny =    data["shiny"]
	efficacy =    data["efficacy"]
	enchantment = data["enchantment"]
	
	mesh =        data["mesh"]
	icon =        data["icon"]

func set_base_properties(data:Dictionary) -> void:
	base_heat         = data["base_heat"]
	base_stability    = data["base_stability"]
	base_volatility   = data["base_volatility"]
	base_density      = data["base_density"]
	base_conductivity = data["base_conductivity"]
	base_purity       = data["base_purity"]
	base_strength     = data["base_strength"]
	base_acidity      = data["base_acidity"]
	base_tags         = data["base_tags"]

func init_current_properties() -> void:
	heat         = base_heat
	stability    = base_stability
	volatility   = base_volatility
	density      = base_density
	conductivity = base_conductivity
	purity       = base_purity
	strength     = base_strength
	acidity      = base_acidity
	tags         = base_tags

func get_data_as_dict() -> Dictionary:
	var data:Dictionary = {}
	data["name"]        = name
	data["type"]        = type
	data["class"]       = item_class
	data["rarity"]      = rarity
	data["mass"]        = mass
	data["shiny"]       = is_shiny
	data["efficacy"]    = efficacy
	data["enchantment"] = enchantment
	data["icon"]        = icon
	data["mesh"]        = mesh
	
	data["base_heat"]         = base_heat
	data["base_stability"]    = base_stability
	data["base_volatility"]   = base_volatility
	data["base_density"]      = base_density
	data["base_conductivity"] = base_conductivity
	data["base_purity"]       = base_purity
	data["base_strength"]     = base_strength
	data["base_acidity"]      = base_acidity
	data["base_tags"]         = base_tags
	
	data["heat"]         = heat
	data["stability"]    = stability
	data["volatility"]   = volatility
	data["density"]      = density
	data["conductivity"] = conductivity
	data["purity"]       = purity
	data["strength"]     = strength
	data["acidity"]      = acidity
	data["tags"]         = tags
	return data
