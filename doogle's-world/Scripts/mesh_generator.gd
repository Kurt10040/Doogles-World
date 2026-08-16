@tool
extends RefCounted
class_name MeshGenerator

static func newMesh(subdivisions:int = 1)->ArrayMesh:
	var surface_array := create_sphere(subdivisions)

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

	return array_mesh

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

static func create_sphere(subdiv:int)->Array:
	var surface_array := create_cube(subdiv)
	
	for i in surface_array[Mesh.ARRAY_VERTEX].size():
		var vertex:Vector3 = surface_array[Mesh.ARRAY_VERTEX][i]
		surface_array[Mesh.ARRAY_VERTEX][i] = vertex.normalized()/2.0
		surface_array[Mesh.ARRAY_NORMAL][i] = vertex.normalized()
		
	return surface_array
