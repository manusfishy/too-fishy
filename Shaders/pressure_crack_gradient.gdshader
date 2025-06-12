shader_type canvas_item;

uniform float gradient_strength : hint_range(0.0, 2.0) = 1.5;
uniform float center_opacity : hint_range(0.0, 1.0) = 0.9;
uniform float edge_opacity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float distance_from_center = distance(UV, center);
    
    // Normalize distance (0.0 at center, 1.0 at edges)
    float normalized_distance = distance_from_center / 0.7071; // sqrt(0.5) for corner distance
    normalized_distance = clamp(normalized_distance, 0.0, 1.0);
    
    // Create gradient: higher opacity at center, lower at edges
    float opacity_multiplier = mix(center_opacity, edge_opacity, normalized_distance * gradient_strength);
    
    // Apply original texture color with gradient opacity
    COLOR = texture(TEXTURE, UV);
    COLOR.a *= opacity_multiplier;
} 