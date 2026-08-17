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

@export var shape: ShapeArchetypes
@export var scale: Vector3
@export var roughness: float
@export var roundness: float
@export var noise_scale: float
@export var noise_seed: int
@export var subdivisions: int
@export var angularity: float
@export var faceted: bool
