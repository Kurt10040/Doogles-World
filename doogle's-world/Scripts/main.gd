extends Node3D

@onready var items: Node3D = $Items
@onready var item_spawn_area: Area3D = $ItemSpawnArea

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_random_items(Global.spawnables,10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

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

func spawn_random_items(spawnable_items:Array,count:int):
	var spawned_count = 0
	var attempts = 0
	
	while spawned_count < count and attempts < 100:
		var area = $ItemSpawnArea/CollisionShape3D
		var rand_pos = get_random_position(area)
		print(spawnable_items[randi() % spawnable_items.size()]["name"], rand_pos)
		spawn_item(spawnable_items[randi() % spawnable_items.size()], rand_pos)
		spawned_count += 1
		attempts += 1

func spawn_item(item_data, item_pos):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	var rigid_body = RigidBody3D.new()
	item_instance.set_item_data(item_data)
	item_instance.global_position = item_pos
	rigid_body.add_child(item_instance)
	items.add_child(rigid_body)
