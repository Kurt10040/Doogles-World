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

@export var shape: ShapeArchetypes = ShapeArchetypes.ROCK
@export var scale: Vector3 = Vector3.ONE
@export var roughness: float = 0.25
@export var roundness: float = 0.5
@export var noise_scale: float = 1.0
@export var noise_seed: int = 1
@export var subdivisions: int = 6
@export var angularity: float = 0
@export var faceted: bool = false
