extends Node3D


@onready var stream_player:AudioStreamPlayer = $bg_music_player
@onready var door_interact:Area3D = $door/Interactable
@onready var whiteout: ColorRect = $CanvasLayer/ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream_player.play(15.5)
	door_interact.interact = _on_interact
	
	whiteout.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(whiteout, "modulate", Color(0,0,0,0), 1.0)
	await tween.finished
	whiteout.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_interact():
	if door_interact.is_interactable:
		door_interact.is_interactable = false
		
		whiteout.mouse_filter = Control.MOUSE_FILTER_STOP
		var tween = create_tween()
		tween.tween_property(whiteout, "modulate", Color(0,0,0,1), 1.0)
		await tween.finished
		
		Global.goto_scene("res://Scenes/main.tscn")
