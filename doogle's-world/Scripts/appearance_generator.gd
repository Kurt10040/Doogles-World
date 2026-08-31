extends RefCounted
class_name AppearanceGenerator

enum CreatureType {
	LEAF,
	WATER,
	ROCK,
	FIRE,
	MAGIC
}
enum CreatureClass {
	FRIENDLY,
	CRITTER,
	HOSTILE,
	BEAST,
}

# Generate an instance of the Appearance class with custom properties
static func generate_appearance(stats:Stats)->Appearance:
	# Determine base appearance
	var subdivisions:int = 6
	var size:float = 2.0
	var shape:Appearance.ShapeArchetypes = Appearance.ShapeArchetypes.ROCK
	
	# create new Appearance class instance
	var appearance:Appearance = Appearance.new()
	appearance.material = StandardMaterial3D.new()
	appearance.core = stats
	
	# Choose shape
	if stats.item_class == stats.ItemClass.ORE and stats.type in [Stats.ItemType.METAL, Stats.ItemType.ROCK]:
		#print("this a rock metal ore thingy")
		appearance.shape = Appearance.ShapeArchetypes.ROCK
		appearance.material.albedo_color = [Color.DIM_GRAY,Color.SADDLE_BROWN].pick_random()
	else:
		print("yea idk what shape this is supposed to have lol so here is a rock")
		appearance.shape = Appearance.ShapeArchetypes.ROCK
		appearance.material.albedo_color = [Color.DIM_GRAY,Color.SADDLE_BROWN, Color.AQUAMARINE, Color.BURLYWOOD, Color.CHARTREUSE, Color.DARK_GREEN].pick_random()

	# Faceted geometry and normals
	if appearance.shape == Appearance.ShapeArchetypes.CRYSTAL or stats.item_class == Stats.ItemClass.CRYSTAL:
		appearance.faceted = true
		appearance.material.albedo_color = [Color.WHITE, Color.AQUA, Color.BLUE_VIOLET].pick_random()
		appearance.material.albedo_color.a = randf_range(0.4,0.8)
		appearance.material.roughness = randf_range(0.05,0.4)
		appearance.material.refraction_enabled = true

	# Edit appearance based on item type
	if stats.type == Stats.ItemType.ROCK:
		appearance.roughness += 0.2
		appearance.angularity += 0.1
		appearance = load("res://Resources/Items/ShapeArchetypes/crystal_base.tres")
	if stats.type == Stats.ItemType.METAL:
		appearance.roughness -= 0.2
		appearance.angularity += 0.15
	if stats.type == Stats.ItemType.WOOD:
		appearance.roughness += 0.15
		appearance.scale *= Vector3(1, 1.2, 1)
	if stats.type == Stats.ItemType.LIQUID:
		appearance.roughness -= 0.2
		appearance.roundness += 0.5

	return appearance
