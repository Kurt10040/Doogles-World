@tool
extends RefCounted
class_name MeshGenerator

static func generate_item_mesh(item_stats:Stats)->ArrayMesh:
	var size:float = 2.0
	
	var appearance:Appearance = AppearanceGenerator.generate_appearance(item_stats)
	#appearance.scale = Vector3(1.6,1.2,1)
	appearance.scale = Vector3(2,2,2)
	appearance.noise_seed = randi_range(1,100)
	
	var surface_array:Array
	if appearance.shape == Appearance.ShapeArchetypes.ROCK:
		surface_array = generate_rock(appearance, size/2.0)
	elif appearance.shape == Appearance.ShapeArchetypes.CRYSTAL:
		surface_array = generate_crystal(appearance, size/2.0)
	elif appearance.shape == Appearance.ShapeArchetypes.BLOB:
		surface_array = generate_blob(appearance, size/2.0)

	#var array_mesh := ArrayMesh.new()
	#array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	var array_mesh := array_to_arraymesh(surface_array)

	return array_mesh

static func array_to_arraymesh(array:Array)->ArrayMesh:
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)

	return array_mesh

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
	var surface_array:Array = create_sphere(appearance.subdivisions, size/2)
	
	
	
	return surface_array



# == MESH DEFORMATIONS ==
static func stretch(original_mesh:Array, stretch_amount:Vector3)->Array:
	var stretched_mesh = original_mesh
	return stretched_mesh
	
static func add_noise(original_mesh:Array, roughness:float, noise_scale:float, noise_seed:int)->Array:
	var final_mesh = original_mesh
	return final_mesh
	
static func add_bulge(original_mesh:Array)->Array:
	var final_mesh = original_mesh
	return final_mesh
	
