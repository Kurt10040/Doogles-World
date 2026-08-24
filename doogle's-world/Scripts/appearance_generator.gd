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
	
	# Choose shape
	if stats.item_class == stats.ItemClass.ORE and stats.type in [Stats.ItemType.METAL, Stats.ItemType.ROCK]:
		#print("this a rock metal ore thingy")
		appearance.shape = Appearance.ShapeArchetypes.ROCK
	else:
		print("yea idk what shape this is supposed to have lol so here is a rock")
		appearance.shape = Appearance.ShapeArchetypes.ROCK

	# Faceted geometry and normals
	if appearance.shape == Appearance.ShapeArchetypes.CRYSTAL or stats.item_class == Stats.ItemClass.CRYSTAL:
		appearance.faceted = true

	# Edit appearance based on item type
	if stats.type == Stats.ItemType.ROCK:
		appearance.roughness += 0.2
		appearance.angularity += 0.1
	if stats.type == Stats.ItemType.METAL:
		appearance.roughness -= 0.2
		appearance.angularity += 0.15
	if stats.type == Stats.ItemType.WOOD:
		appearance.scale *= Vector3(1, 1.2, 1)
		appearance.roughness += 0.15
	if stats.type == Stats.ItemType.LIQUID:
		appearance.roundness += 0.5
		appearance.roughness -= 0.2

	return appearance
