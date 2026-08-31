class_name TransmutationSystem

const combos:Dictionary = {
	
}

static func combine(item_a:Stats, item_b:Stats, environment: Dictionary) -> Stats:
	var item_a_dict:Dictionary = item_a.get_data_as_dict()
	var item_b_dict:Dictionary = item_b.get_data_as_dict()
	
	print("Combining "+item_a.name+" with "+item_b.name)
	var result_item:Stats = create_base(item_a,item_b)
	
	result_item = apply_environment(result_item, environment)
	result_item = combine_properties(result_item,item_a,item_b)
	result_item = apply_reactions(result_item,item_a,item_b)
	result_item = apply_builtin_recipes(result_item,item_a,item_b)
	# Determine enchantments
	result_item = determine_class_and_type(result_item,item_a,item_b)
	result_item = determine_tags(result_item,item_a,item_b)
	result_item = determine_rarity(result_item, item_a, item_b)
	# Determine name
	result_item.name = item_a.name+item_b.name
	
	# Generate appearance
	#var appearance = AppearanceGenerator.generate_appearance(result_item)
	#var result_mesh = MeshGenerator.generate_item_mesh(result_item)
	
	# Return final transmutated item
	return result_item

static func create_base(item_a:Stats,item_b:Stats) -> Stats:
	var result:Stats = Stats.new()
	var bias:float = 0.6
	
	# normal addition unless its a gas
	result.mass = item_a.mass + item_b.mass
	
	# slight bias towards the higher value
	result.base_heat = lerp(item_a.heat,item_b.heat, bias)
	
	# Normal average
	result.base_stability = lerp(item_a.stability,item_b.stability, 0.5)
	
	# no bias unless its super big difference
	result.base_volatility = (item_a.volatility + item_b.volatility)/2.0
	
	# bias towards the lower value minus a little bit from defects due to crafting. 
	# defects calculated from heat, density, volatility, and stability
	result.base_purity = lerp(item_a.purity, item_b.purity, (0.5 - bias/8.0))
	result.base_purity = lerp(result.base_purity, (result.base_stability + result.base_volatility)/2, 0.33) # defects based on properties
	result.base_purity += (abs(item_a.base_heat - item_a.heat) + abs(item_b.base_heat - item_b.heat))/(result.base_heat*2.0)
	
	# bias towards the lower by a little + resistance from purity/impurity
	result.base_conductivity = lerp(item_a.base_conductivity, item_b.base_conductivity, (0.5 - bias/12.0) + (1.0 - result.base_purity)/5.0)
	
	# Add the strength of both items and add a little bit
	result.base_strength = item_a.strength + item_b.strength
	result.base_strength += min(item_a.base_strength, item_b.base_strength)/2.0
	
	# Bias towards the higher value
	var more_acidic:int = max(item_a.acidity,item_b.acidity)
	var less_acidic:int = min(item_a.acidity,item_b.acidity)
	result.base_acidity = lerp(less_acidic, more_acidic, 0.7)
	
	# Calculate using size divide by mass
	result.base_density = (result.mass * result.base_strength)
	
	return result

static func apply_environment(result:Stats, environment:Dictionary) -> Stats:
	if environment == {}:
		return result
	
	result.heat += environment.get("heat", 0.0)
	
	return result

static func combine_properties(result:Stats,item_a:Stats,item_b:Stats) -> Stats:
	return result

static func apply_reactions(result:Stats,item_a:Stats,item_b:Stats) -> Stats:
	# Freezing
	if result.heat <= 1.0:
		if result.type == Stats.ItemType.LIQUID:
			result.item_class = Stats.ItemClass.CRYSTAL
			result.tags.append("Frozen")
		
	# Alloy
	if item_a.type == Stats.ItemType.METAL and item_b.type == Stats.ItemType.METAL:
		result.type = Stats.ItemType.METAL
		result.tags.append({"Alloy": str(item_a.name + " " + item_b.name)})
		
	# High heat + high volatility example
	if result.heat > 80.0 and result.volatility > 0.89:
		result.stability -= 0.3
		result.volatility += 0.05
		
		if result.volatility >= 1.0:
			print(result.name, " has exploded")
	
	
	
	return result

static func apply_builtin_recipes(result:Stats,item_a:Stats,item_b:Stats) -> Stats:
	return result
	
static func determine_class_and_type(result:Stats,item_a:Stats,item_b:Stats) -> Stats:
	if item_a.type == item_b.type:
		result.type = item_a.type
	else:
		result.type = [item_a.type,item_b.type].pick_random()
	
	if item_a.item_class == item_b.item_class:
		result.item_class = item_a.item_class
	else:
		result.item_class = [item_a.item_class,item_b.item_class].pick_random()
	
	return result

static func determine_tags(result:Stats,item_a:Stats,item_b:Stats) -> Stats:
	if result.item_class == Stats.ItemClass.ORGANIC and result.type == Stats.ItemType.PLANT:
		result.tags.append("Nature")
	
	if result.item_class == Stats.ItemClass.WEARABLE and result.type in [Stats.ItemType.METAL, Stats.ItemType.WOOD, Stats.ItemType.CREATURE_DROPS]:
		result.tags.append("Armor")
	
	return result
	
static func determine_rarity(result:Stats, item_a:Stats, item_b:Stats) -> Stats:
	var new_rarity:int = (item_a.rarity as int + item_b.rarity as int)/2
	result.rarity = Stats.ItemRarity.values()[new_rarity]
	
	return result

static func determine_appearance(result:Stats):
	pass
