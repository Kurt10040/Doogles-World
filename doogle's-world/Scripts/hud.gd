extends CanvasLayer


@onready var interaction_prompt: Label = $InteractionPrompt

# Target function for the 'interact_prompt_change' signal. This function changes the text of the interaction label/prompt
func update_prompt(text: String):
	if text != "":
		interaction_prompt.text = text
		interaction_prompt.show()
	else:
		interaction_prompt.hide()
