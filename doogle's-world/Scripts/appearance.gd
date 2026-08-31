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

@export_group("Base Material")
## Core material of type Stats that the appearance will be based off of 
@export var core:Stats
@export var material:StandardMaterial3D
## Mesh shape archetype 
@export var shape: ShapeArchetypes = ShapeArchetypes.ROCK
## Mesh 3D scale 
@export var scale: Vector3 = Vector3.ONE
## Mesh subdivisions amount 
@export var subdivisions: int = 8 
## Intensity of noise
@export var roughness: float = 0.25
@export var roundness: float = 0.5
## Scale of noise texture
@export var noise_scale: float = 1.0
@export var noise_seed: int = 1
@export var angularity: float = 0
@export var faceted: bool = false

@export_group("Anatomy")
@export_subgroup("Limbs")
## Number of limbs the creature has
@export var limb_count:int = 4
## Length of creature's limbs
@export var limb_length:float = 1.0
@export_subgroup("Features")
## Number of eyes of creature
@export var eye_count:int = 2
## Number of horns of creature
@export var horn_count:int = 1
## Size of creature's horn/s
@export var horn_size:float = 1.0
## Size of creature's tail, if applicable
@export var tail_size:float = 0.0
