extends CharacterBody3D


@onready var interact_component = $InteractComponent
@onready var inventory_ui = $InventoryUI
@onready var menu = $Menu


# Constants for player movement calculations
const SPEED = 4.0
const JUMP_VELOCITY = 4.5
const navigation_speed = 1.0

func _ready() -> void:
	Global.set_player_ref(self)   # Set a global reference to the player scene object

func _physics_process(delta: float) -> void:
	# Skip the calculations if game is paused
	if get_tree().paused:
		return
	# Gravity.
	if not is_on_floor() and !get_tree().paused:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")    # WASD movement
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	#if not get_tree().paused:
	move_and_slide()

	# Smooth Camera Tracking
	$CameraController.position = lerp($CameraController.position, position,.08)

# Listener for input events
func _input(event):
	# Toggle inventory
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
	
	# Toggle pause menu
	if event.is_action_pressed("menu"):
		menu.visible = !menu.visible
		get_tree().paused = !get_tree().paused
