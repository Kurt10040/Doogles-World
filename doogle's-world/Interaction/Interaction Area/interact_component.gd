extends Node3D

@onready var hud = $"../HUD"
signal interact_prompt_change(text: String)

var current_interactions := []
var can_interact: bool = true

func _ready() -> void:
	interact_prompt_change.connect(hud.update_prompt)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions: # Only run if the player is in range of any interactable objects
			can_interact = false # debounce
			
			hide_prompt()
			await current_interactions[0].interact.call() # Call the custom function of the interactable object
			
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_nearest) # Use custom storting function to find nearest interactable object
		if current_interactions[0].is_interactable:
			# Show interaction label
			var interactKeybind: InputEventKey = InputMap.action_get_events("interact")[0]
			show_prompt("[" + interactKeybind.as_text_physical_keycode() + "] " + current_interactions[0].interact_name)
	else:
		hide_prompt()

# Sort the interactions list by closest to the player
func _sort_nearest(area1:Variant, area2:Variant)->Variant:
	var area1_dist:float = global_position.distance_to(area1.global_position)
	var area2_dist:float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

# Add the interaction object into list
func _on_interact_range_area_entered(area: Area3D) -> void:
	current_interactions.push_back(area)

# Remove interaction object from list
func _on_interact_range_area_exited(area: Area3D) -> void:
	current_interactions.erase(area)

func show_prompt(text: String)->void:
	interact_prompt_change.emit(text)

func hide_prompt()->void:
	interact_prompt_change.emit("")
	
