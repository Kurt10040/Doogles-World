@tool
extends Node3D

@export_group("Source")
@export_file("*.mesh", "*.tres", "*.res") var mesh_path: String

@export_group("Output")
@export var multimesh_name: String = "FoliageMultiMesh"

@export_tool_button("Convert Foliage", "Callable")
var convert_button = convert_foliage


func convert_foliage() -> void:
	if mesh_path.is_empty():
		push_error("Foliage: No mesh path specified.")
		return

	var foliage_mesh = load(mesh_path) as Mesh

	if foliage_mesh == null:
		push_error("Foliage: Could not load mesh at: " + mesh_path)
		return

	var instances: Array[MeshInstance3D] = []

	var parent_node:Node = $"../Rocky/Rock4"
	_find_mesh_instances(parent_node, instances)

	if instances.is_empty():
		push_warning("Foliage: No MeshInstance3D nodes found.")
		return

	print("Found ", instances.size(), " foliage instances.")

	# Create the MultiMesh
	var multimesh := MultiMesh.new()

	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = foliage_mesh
	multimesh.instance_count = instances.size()

	# Convert every existing instance into a MultiMesh transform
	for i in range(instances.size()):
		var instance: MeshInstance3D = instances[i]

		var local_transform := (
			global_transform.affine_inverse()
			* instance.global_transform
		)

		multimesh.set_instance_transform(
			i,
			local_transform
		)

	# Create the MultiMeshInstance3D
	var multimesh_instance := MultiMeshInstance3D.new()

	multimesh_instance.name = multimesh_name
	multimesh_instance.multimesh = multimesh

	add_child(multimesh_instance)

	# Make the generated node part of the scene
	multimesh_instance.owner = get_tree().edited_scene_root

	print("Created MultiMesh with ",instances.size()," instances")


func _find_mesh_instances(node:Node, result:Array[MeshInstance3D]) -> void:

	for child in node.get_children():

		if child is MeshInstance3D:
			result.append(child)
		elif child is Node3D:
			_find_mesh_instances(child, result)
