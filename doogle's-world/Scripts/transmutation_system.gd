extends RefCounted
class_name TransmutationSystem

static func combine(item_a:Stats, item_b:Stats, environment: Dictionary) -> Stats:
	var item_a_dict = item_a.get_data_as_dict()
	var item_b_dict = item_b.get_data_as_dict()
	
	print("Item A: "+str(item_a_dict))
	print("Item B: "+str(item_b_dict))
	print("Combining "+item_a.name+" with "+item_b.name)
	
	
	var result_item := create_base(item_a,item_b)
	
	# apply environment modifiers
	#apply_environment(result_item, environment)
	
	# Calculate combined properties
	
	# apply reaction rules; custom/built-in recipes
	
	# Determine class, type, tags
	if result_item.item_class == Stats.ItemClass.ORGANIC and result_item.type == Stats.ItemType.PLANT:
		result_item.tags.append("Nature")
	
	# Determine rarity
	
	# Generate new Stats object
	
	# Return final transmutated item
	return result_item

static func create_base(item_a:Stats,item_b:Stats) -> Stats:
	var result := Stats.new()
	var bias := 0.6
	
	# normal addition unless its a gas
	result.mass = item_a.mass + item_b.mass
	print("new mass: "+str(result.mass))
	
	# Calculate using size divide by mass
	result.base_density = (result.mass * result.base_strength)
	print("new density: "+str(result.base_density))
	
	# slight bias towards the higher value
	result.base_heat = lerp(item_a.heat,item_b.heat, bias)
	print("new heat: "+str(result.base_heat))
	
	# Normal average
	result.base_stability = lerp(item_a.stability,item_b.stability, 0.5)
	print("new stability: "+str(result.base_stability))
	
	# no bias unless its super big difference
	result.base_volatility = (item_a.volatility + item_b.volatility)/2.0
	print("new volatility: "+str(result.base_volatility))
	
	# bias towards the lower value minus a little bit from defects due to crafting. 
	# defects calculated from heat, density, volatility, and stability
	result.base_purity = lerp(item_a.purity, item_b.purity, (0.5 - bias/8.0))
	print("new purity: "+str(result.base_purity))
	result.base_purity = lerp(result.base_purity, (result.base_stability + result.base_volatility)/2, 0.33) # defects based on properties
	print("new purity after volatility/stability defects: "+str(result.base_purity))
	result.base_purity += (abs(item_a.base_heat - item_a.heat) + abs(item_b.base_heat - item_b.heat))/(result.base_heat*2.0)
	print("new purity after heat defects: "+str(result.base_purity))
	
	# bias towards the lower by a little + resistance from purity/impurity
	result.base_conductivity = lerp(item_a.base_conductivity, item_b.base_conductivity, (0.5 - bias/12.0) + (1.0 - result.base_purity)/5.0)
	print("new conductivity: "+str(result.base_conductivity))
	
	# Add the strength of both items and add a little bit
	result.base_strength = item_a.strength + item_b.strength
	print("new strength: "+str(result.base_strength))
	result.base_strength += min(item_a.base_strength, item_b.base_strength)/2.0
	print("new strength after addition: "+str(result.base_strength))
	
	# Bias towards the higher value
	var more_acidic = max(item_a.acidity,item_b.acidity)
	var less_acidic = min(item_a.acidity,item_b.acidity)
	result.base_acidity = lerp(less_acidic, more_acidic, 0.7)
	print("new acidity: "+str(result.base_acidity))
	
	return result

static func apply_environment(result,environment):
	return result

static func combine_properties(result,item_a,item_b):
	return result

static func apply_reactions(result,item_a,item_b):
	return result

static func apply_builtin_recipes(result,item_a,item_b):
	return result
	
static func determine_class_and_type(result,item_a,item_b):
	return result

@warning_ignore("unused_parameter")
static func determine_tags(result,item_a,item_b):
	return result
	
static func determine_rarity(result):
	return result
