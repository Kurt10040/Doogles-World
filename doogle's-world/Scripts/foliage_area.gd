@tool
extends Node3D

@export_group("Foliage")
@export var foliage_mesh: Mesh:
	set(value):
		foliage_mesh = value
		if Engine.is_editor_hint():
			_update_multimesh()

@export_group("Area")
@export var area_size:Vector2
@export var area_density:float

@export_group("Generation")
@export_range(1,500,1) var instance_count:int = 100
@export var generation_seed:int = 1

@export_group("Randomization")
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var random_rotation: bool = true

@export_group("Editor")
@export_tool_button("Generate Foliage", "Callable") var generate_button = generate_foliage
@export_tool_button("Clear Foliage", "Callable") var clear_button = clear_foliage

var foliage_multimesh: MultiMeshInstance3D
var multimesh: MultiMesh



func _ready() -> void:
	if Engine.is_editor_hint():
		_setup_multimesh()


func _setup_multimesh() -> void:
	if foliage_multimesh == null:
		foliage_multimesh = get_node_or_null("Foliage")

	if foliage_multimesh == null:
		foliage_multimesh = MultiMeshInstance3D.new()
		foliage_multimesh.name = "Foliage"
		add_child(foliage_multimesh)

		# Make sure the generated node is saved into the scene.
		foliage_multimesh.owner = get_tree().edited_scene_root

	if foliage_multimesh.multimesh == null:
		multimesh = MultiMesh.new()
		foliage_multimesh.multimesh = multimesh
	else:
		multimesh = foliage_multimesh.multimesh

	_update_multimesh()


func _update_multimesh() -> void:
	if not Engine.is_editor_hint():
		return

	if foliage_multimesh == null:
		return

	if foliage_mesh == null:
		foliage_multimesh.multimesh = null
		return

	if multimesh == null:
		multimesh = MultiMesh.new()

	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = false
	multimesh.use_custom_data = false

	multimesh.mesh = foliage_mesh
	foliage_multimesh.multimesh = multimesh


func generate_foliage() -> void:
	if not Engine.is_editor_hint():
		return

	if foliage_mesh == null:
		push_warning("FoliageArea: No foliage mesh assigned.")
		return

	_setup_multimesh()

	multimesh.instance_count = instance_count

	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed

	for i in range(instance_count):
		var pos := Vector3(
			rng.randf_range(-area_size.x / 2.0, area_size.x / 2.0),
			0.0,
			rng.randf_range(-area_size.y / 2.0, area_size.y / 2.0)
		)

		var rotation_y := 0.0

		if random_rotation:
			rotation_y = rng.randf_range(0.0, TAU)

		var scale_n := rng.randf_range(min_scale, max_scale)

		var transform_n := Transform3D()
		transform_n.origin = pos
		transform_n.basis = Basis(Vector3.UP, rotation_y).scaled(
			Vector3(scale_n, scale_n, scale_n)
		)

		multimesh.set_instance_transform(i, transform_n)


func clear_foliage() -> void:
	if not Engine.is_editor_hint():
		return

	if multimesh != null:
		multimesh.instance_count = 0
