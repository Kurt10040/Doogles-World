extends Resource
class_name Appearance

enum ShapeArchetypes {
	ROCK,
	CRYSTAL,
	BLOB,
	SHARD,
	PARTICLE,
	FLUID,
	MANUFACTURED,
	CONTAINER,
	EQUIPMENT
}

@export_group("Material")
@export var core:Stats
@export var subdivisions: int = 6
@export var roughness: float = 0.25
@export var roundness: float = 0.5
@export var noise_scale: float = 1.0
@export var noise_seed: int = 1
@export var angularity: float = 0
@export var faceted: bool = false

@export_group("Anatomy")
@export var scale: Vector3 = Vector3.ONE
@export var shape: ShapeArchetypes = ShapeArchetypes.ROCK
@export_subgroup("Limbs")
@export var limb_count:int = 4
@export var limb_length:float = 1.0
@export_subgroup("Features")
@export var eye_count:int = 2
@export var horn_count:int = 1
@export var horn_size:float = 1.0
@export var tail_size:float = 0.0
