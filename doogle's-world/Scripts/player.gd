extends CharacterBody3D


@onready var interact_component = $InteractComponent
@onready var inventory_ui = $InventoryUI
@onready var menu = $Menu
@onready var crafting_ui = $CraftingMenu

@onready var player_mesh:Node3D = $PlayerMesh
@onready var animation_player:AnimationPlayer = $PlayerMesh/AnimationPlayer

# Constants for player movement calculations
var player_speed = 6
const JUMP_VELOCITY = 4.5
const navigation_speed = 1.0
var player_direction:float = 0.0
var mesh_direction:float = 0.0
var camera_dir:float = 0.0
var look_down:int = 0

func _ready() -> void:
	Global.set_player_ref(self)   # Set a global reference to the player scene object

func _physics_process(delta: float) -> void:
	# Skip the calculations if game is paused
	if get_tree().paused:
		return
	# Gravity.
	if not is_on_floor() and !get_tree().paused:
		velocity += get_gravity() * delta
		#animation_player.play("Main Jump",-1,-1,true)

	# Handle jump.
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("Main Jump",-1,2,false)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")    # WASD movement
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		camera_dir = rotation.y*(180/PI) - 15*input_dir.x
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
		mesh_direction = atan2(input_dir.x, input_dir.y) + deg_to_rad(player_direction)
		
		if is_on_floor_only():
			animation_player.play("Run",-1,3)
		else:
			animation_player.pause()
				
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)
		animation_player.play("Idle_nervous")
	
	rotation.y = lerp_angle(rotation.y, player_direction*(PI/180), 0.1)
	
	
	move_and_slide()

	# Smooth Camera Tracking
	$CameraController.position = lerp($CameraController.position, position,.08)
	$CameraController.rotation.y = lerp_angle($CameraController.rotation.y, rotation.y, 0.08)
	$CameraController.rotation.z = lerp_angle($CameraController.rotation.z, rotation.z - 3.5*input_dir.x*PI/180, 0.03)
	$CameraController.rotation.x = lerp_angle($CameraController.rotation.x, rotation.x - 15*look_down*PI/180, 0.2)
	
	var sprint = int(Input.is_action_pressed("player_sprint"))
	$CameraController/CameraTarget/OverheadCamera.fov = lerp($CameraController/CameraTarget/OverheadCamera.fov, 40.0 + (5.0*sprint), 0.1)
	
	player_mesh.global_rotation.y = lerp_angle(player_mesh.global_rotation.y, mesh_direction, 0.2)
# Listener for input events
func _input(event):
	# Toggle inventory
	if event.is_action_pressed("inventory"):
		if !crafting_ui.visible:
			inventory_ui.visible = !inventory_ui.visible
	
	# Toggle pause menu
	if event.is_action_pressed("menu"):
		menu.visible = !menu.visible
		get_tree().paused = !get_tree().paused
		
	if event.is_action_pressed("rotate_player_left"):
		player_direction += 15
		if player_direction >= 360:
			player_direction = 0
	
	if event.is_action_pressed("rotate_player_right"):
		player_direction -= 15
		if player_direction <= -360:
			player_direction = 0
			
	if event.is_action_pressed("player_sprint"):
		player_speed = 10
	elif event.is_action_released("player_sprint"):
		player_speed = 6


func _on_close_button_pressed() -> void:
	crafting_ui.visible = false
