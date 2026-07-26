shader_type canvas_item;

// This pulls the screen's current image into the shader
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// This lets you choose your target color from the Inspector
uniform vec4 target_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Read the exact color from the screen behind the ColorRect
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    
    // Apply your chosen color (here we tint the screen color)
    vec4 final_color = screen_color * target_color;
    
    // Output the final color to the screen
    COLOR = final_color;
}
