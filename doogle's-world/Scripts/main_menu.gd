extends Node3D

var main_scene = "res://Scenes/main.tscn"
var homebase_scene = "res://Scenes/homebase.tscn"

@onready var camera:Camera3D = $Camera3D
@onready var camera_views:Node3D = $CameraViews
var current_view:Node3D
var next_view:Node3D

@onready var whiteout: ColorRect = $CanvasLayer/ColorRect
@onready var play_button:Button = $CanvasLayer/Button
@onready var stream_player:AudioStreamPlayer = $bg_music_player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	whiteout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var bg_music:Array = ["res://Assets/Sounds/SFX/Music/blossom.wav", "res://Assets/Sounds/SFX/Music/regrowth wip.wav", "res://Assets/Sounds/SFX/Music/start.wav"]
	stream_player.stream = load(bg_music[randi_range(0,2)])
	stream_player.play()
	
	current_view = camera_views.get_children()[randi_range(0,camera_views.get_children().size() - 1)]
	while next_view == null or next_view == current_view:
		next_view =camera_views.get_children()[randi_range(0,camera_views.get_children().size() - 1)]
	
	camera.global_position = current_view.global_position
	camera.global_rotation = current_view.global_rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera.global_position = lerp(camera.global_position,next_view.global_position, 0.001)
	camera.global_rotation = lerp(camera.global_rotation,next_view.global_rotation, 0.001)
	
	if camera.global_position.distance_squared_to(next_view.global_position) < 400:
		current_view = next_view
		while next_view == current_view:
			next_view = camera_views.get_children()[randi_range(0,camera_views.get_children().size() - 1)]


func _on_button_pressed() -> void:
	# Block mouse input
	whiteout.visible = true
	whiteout.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(whiteout, "modulate", Color(0,0,0,1), 1.0)
	await tween.finished
	
	Global.goto_scene(main_scene)
