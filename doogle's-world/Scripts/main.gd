extends Node3D

@onready var items: Node3D = $Items
@onready var item_spawn_area: Area3D = $ItemSpawnArea

@onready var stream_player:AudioStreamPlayer = $bg_music_player
@onready var whiteout: ColorRect = $CanvasLayer/ColorRect

# Called when the node enters the scene tree for the f$CanvasLayer/ColorRectirst time.
func _ready():
	var bg_music:Array = ["res://Assets/Sounds/SFX/Music/blossom.wav", "res://Assets/Sounds/SFX/Music/journey.wav", "res://Assets/Sounds/SFX/Music/regrowth wip.wav", "res://Assets/Sounds/SFX/Music/start.wav"]
	stream_player.stream = load(bg_music[randi_range(0,3)])
	stream_player.volume_db = -15
	stream_player.play()
	
	for area in item_spawn_area.get_children():
		spawn_random_items(Global.spawnables,15, area)
	
	whiteout.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(whiteout, "modulate", Color(0,0,0,0), 1.0)
	await tween.finished
	whiteout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

# Get a random 3d position within the area
func get_random_position(area:CollisionShape3D):
	# Make sure that the given area is a box shape
	var box = area.shape as BoxShape3D
	
	if not box:
		return area.global_position
	
	# Get half the size so we can give an offset from the center of the area
	var extents = box.size/2
	# generate random offsets within the area
	var offset = Vector3(randf_range(-extents.x,extents.x),randf_range(-extents.y,extents.y),randf_range(-extents.z,extents.z))
	
	return area.global_transform * offset

# Spawn a specified number of random items picked from a list
func spawn_random_items(spawnable_items:Array,count:int, area:CollisionShape3D):
	var spawned_count = 0
	var attempts = 0
	
	while spawned_count < count and attempts < 100:
		var rand_pos = get_random_position(area)
		
		var item = spawnable_items[randi() % spawnable_items.size()]
		var item_stats = Stats.new()
		item_stats.set_base_properties(item)
		item_stats.set_identity(item)
		var new_mesh = MeshGenerator.generate_item_mesh(item_stats)
		item["mesh"] = new_mesh
		spawn_item(item, rand_pos)
		spawned_count += 1
		attempts += 1

# Spawn an individual item into the 3d world
func spawn_item(item_data, item_pos):
	# Load and instance a new item node
	var item_scene = load(item_data["scene_path"])
	var item_instance: Node3D = item_scene.instantiate()
	
	# Set item instance data 
	item_instance.set_item_data(item_data)
	
	# Add physics nodes in the new item instance
	var rigid_body := RigidBody3D.new()
	var collision_shape := CollisionShape3D.new()
	rigid_body.add_child(collision_shape)
	rigid_body.add_child(item_instance)
	
	item_instance.position = Vector3.ZERO
	item_instance.rotation = Vector3.ZERO
	
	# Reparenting
	items.add_child(rigid_body)
	
	# Collision
	var item_mesh: Mesh = item_instance.object_mesh.mesh
	var convex:ConvexPolygonShape3D = item_mesh.create_convex_shape()
	collision_shape.shape = convex
	collision_shape.transform = item_instance.object_mesh.transform
	
	rigid_body.set_collision_layer_value(1,false)
	rigid_body.set_collision_layer_value(3,true)
	
	rigid_body.set_collision_mask_value(1,true)
	rigid_body.set_collision_mask_value(2,true)
	rigid_body.set_collision_mask_value(3,true)

	rigid_body.global_position = item_pos
	
	# Set interaction range for the item
	var aabb: AABB = item_mesh.get_aabb()
	var max_radius = aabb.size.length() / 2.0
	var extents = aabb.size / 2.0
	var avg_radius = (extents.x + extents.y + extents.z) / 3.0
	
	var new_range = SphereShape3D.new()
	new_range.radius = avg_radius
	item_instance.find_child("InteractRangeCol").shape = new_range
