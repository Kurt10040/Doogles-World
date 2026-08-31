@tool
extends RefCounted
class_name MeshGenerator

static func generate_item_mesh(item_stats:Stats)->ArrayMesh:
	var size:float = 2.0
	
	var appearance:Appearance = AppearanceGenerator.generate_appearance(item_stats)
	#appearance.scale = Vector3(1.6,1.2,1)
	#appearance.scale = Vector3(2,2,2)
	appearance.noise_seed = randi_range(1,100)
	#appearance.shape = Appearance.ShapeArchetypes.BLOB
	
	var surface_array:Array
	if "Creature" in item_stats["tags"]:
		print("generating creature mesh")
		surface_array = generate_creature(appearance)
	else:
		surface_array = determine_base_shape(appearance)
		
	if appearance.faceted == true:
		surface_array = make_faceted(surface_array)

	var array_mesh:ArrayMesh = array_to_arraymesh(surface_array)
	
	array_mesh.surface_set_material(0, appearance.material)

	return array_mesh

static func array_to_arraymesh(array:Array)->ArrayMesh:
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)

	return array_mesh

static func determine_base_shape(appearance:Appearance)->Array:
	var surface_array:Array
	var size = (appearance.scale.x + appearance.scale.z)/2
	
	if appearance.shape == Appearance.ShapeArchetypes.ROCK or appearance.shape == Appearance.ShapeArchetypes.CRYSTAL:
		surface_array = generate_rock(appearance, size/2.0)
	elif appearance.shape == Appearance.ShapeArchetypes.BLOB:
		surface_array = generate_blob(appearance, size/2.0)
	
	return surface_array

# == BASE GEOMETRY SHAPES ==
static func create_plane(subdiv:int, index:int, direction:Vector3, center:Vector3)->Array:
	var surface_array:Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var positions := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	
	direction = direction.normalized()
	var binormal = Vector3(direction.z, direction.x, direction.y)/subdiv
	var tangent = binormal.rotated(direction, PI/2.0)
	var offset = -subdiv * (binormal + tangent)/2 + center
	
	for x in subdiv:
		for y in subdiv:
			var vertex_offset = binormal * x + tangent * y + offset
			var index_offset = 4 * (x * subdiv + y) + index
			
			positions.append_array([
				vertex_offset,
				vertex_offset + tangent,
				vertex_offset + binormal + tangent,
				vertex_offset + binormal
			])
			normals.append_array([
				direction, direction, direction, direction
			])
			indices.append_array([
				index_offset, index_offset + 1, index_offset + 2,
				index_offset, index_offset + 2, index_offset + 3
			])
	
	surface_array[Mesh.ARRAY_VERTEX] = positions
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	return surface_array

static func create_cube(subdiv:int)->Array:
	var surface_array:Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var positions := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	
	const directions:PackedVector3Array = [
		Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK
	]
	
	for i in directions.size():
		var index = 4 * i * subdiv * subdiv
		var plane = create_plane(subdiv, index, directions[i], directions[i]/2)
		positions.append_array(plane[Mesh.ARRAY_VERTEX])
		normals.append_array(plane[Mesh.ARRAY_NORMAL])
		indices.append_array(plane[Mesh.ARRAY_INDEX])
	
	surface_array[Mesh.ARRAY_VERTEX] = positions
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	return surface_array

static func create_sphere(subdiv:int, radius:float)->Array:
	# initialize a base cube for the vertices
	var surface_array:Array = create_cube(subdiv)
	
	# Loop through each vertex in the sphere
	for i in surface_array[Mesh.ARRAY_VERTEX].size():
		# Grab vertex coordinates
		var vertex:Vector3 = surface_array[Mesh.ARRAY_VERTEX][i]
		
		# Normalize the distance of the vertex from the center with the radius for scaling
		surface_array[Mesh.ARRAY_VERTEX][i] = vertex.normalized() * radius
		surface_array[Mesh.ARRAY_NORMAL][i] = vertex.normalized() # adjust normals for smooth shading
		
	return surface_array

static func make_faceted(surface_array:Array)->Array:
	var old_positions: PackedVector3Array = surface_array[Mesh.ARRAY_VERTEX]
	var old_indices: PackedInt32Array = surface_array[Mesh.ARRAY_INDEX]

	var positions := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()

	for i in range(0, old_indices.size(), 3):
		var a: Vector3 = old_positions[old_indices[i]]
		var b: Vector3 = old_positions[old_indices[i + 1]]
		var c: Vector3 = old_positions[old_indices[i + 2]]

		# Match triangle winding order.
		var face_normal := (b - a).cross(a - c).normalized()

		var start_index := positions.size()

		# Three unique vertices for this triangle.
		positions.append(a)
		positions.append(b)
		positions.append(c)

		# The same normal is assigned to all three vertices.
		normals.append(face_normal)
		normals.append(face_normal)
		normals.append(face_normal)

		indices.append(start_index)
		indices.append(start_index + 1)
		indices.append(start_index + 2)

	var faceted_array: Array = []
	faceted_array.resize(Mesh.ARRAY_MAX)

	faceted_array[Mesh.ARRAY_VERTEX] = positions
	faceted_array[Mesh.ARRAY_NORMAL] = normals
	faceted_array[Mesh.ARRAY_INDEX] = indices

	return faceted_array


# == SHAPE GENERATORS ==
static func generate_rock(appearance:Appearance, radius:float)->Array:
	# initialize a base sphere
	var surface_array:Array = create_sphere(appearance.subdivisions, radius)
	
	# Create a noise profile with the given parameters
	var noise := FastNoiseLite.new()
	noise.seed = appearance.noise_seed
	noise.frequency = appearance.noise_scale
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	# Loop through each vertex in the sphere
	for i in surface_array[Mesh.ARRAY_VERTEX].size():
		var vertex:Vector3 = surface_array[Mesh.ARRAY_VERTEX][i] # Grab the vertex coordinates
		vertex *= appearance.scale # Stretch
		var vertex_dir:Vector3 = vertex.normalized()
		# Apply noise displacement
		var noise_value = noise.get_noise_3d(vertex_dir.x, vertex_dir.y, vertex_dir.z)
		var displacement = noise_value * appearance.roughness * radius
		
		surface_array[Mesh.ARRAY_VERTEX][i] = vertex_dir * (vertex.length() + displacement)
	
	return surface_array

static func generate_crystal(appearance:Appearance, size:float)->Array:
	# initialize a base shape
	var surface_array:Array = create_cube(appearance.subdivisions)
	
	
	
	return surface_array

static func generate_blob(appearance:Appearance, size:float)->Array:
	# initialize a base shape
	var surface_array:Array = create_sphere(appearance.subdivisions, size)
	
	return surface_array

static func generate_creature(appearance:Appearance)->Array:
	var surface_array:Array = determine_base_shape(appearance)
	var radius = (appearance.scale.x + appearance.scale.z)/4
	
	# Add nubs for legs
	surface_array = add_bulge(surface_array, radius, Vector3.FORWARD + Vector3.DOWN + Vector3.LEFT, .5, radius/2)
	surface_array = add_bulge(surface_array, radius, Vector3.FORWARD + Vector3.DOWN + Vector3.RIGHT, .5, radius/2)
	surface_array = add_bulge(surface_array, radius, Vector3.BACK + Vector3.DOWN + Vector3.LEFT, .5, radius/2)
	surface_array = add_bulge(surface_array, radius, Vector3.BACK + Vector3.DOWN + Vector3.RIGHT, .5, radius/2)
	
	surface_array = add_bulge(surface_array, radius, Vector3.FORWARD + Vector3.UP, .5, radius * 1.5)
	surface_array = add_bulge(surface_array, radius, Vector3.BACK + Vector3.DOWN * 0.5, .4, radius * 1.75)
	
	
	return surface_array

# == MESH DEFORMATIONS ==
static func stretch(original_mesh:Array, stretch_amount:Vector3)->Array:
	var stretched_mesh = original_mesh
	return stretched_mesh
	
static func add_noise(original_mesh:Array, roughness:float, noise_scale:float, noise_seed:int)->Array:
	var final_mesh = original_mesh
	return final_mesh
	
static func add_bulge(original_mesh:Array, sphere_radius:float, direction:Vector3, strength:float, radius:float)->Array:
	var surface_array = original_mesh
	var position:Vector3 = direction.normalized() * sphere_radius
	
	direction = direction.normalized()
	
	for i in surface_array[Mesh.ARRAY_VERTEX].size():
		var vertex:Vector3 = surface_array[Mesh.ARRAY_VERTEX][i] # Grab the vertex coordinates
	
		# Determine vertex distance to bulge point
		var distance = vertex.distance_to(position)
		if distance < radius:
			# Determine falloff/influence
			var influence = 1.0 - (distance / radius)
			influence = influence * influence * (3.0 - 2.0 * influence) # makes falloff smoother
			
			vertex += direction * strength * influence
			surface_array[Mesh.ARRAY_VERTEX][i] = vertex
			
	return surface_array
