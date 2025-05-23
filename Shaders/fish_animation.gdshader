shader_type spatial;

// render_mode unshaded; // Standard lighting is currently enabled

uniform sampler2D albedo_texture; // Texture for albedo
uniform sampler2D emission_texture;
uniform float emission_energy = 1.0;

uniform float animation_time_input = 0.0; // Custom time input from script

uniform float pivot = 1.0;
uniform float wave = 1.0;
uniform float twist = 1.0;

// New uniforms for axis selection and calibration
uniform int primary_axis = 0; // 0 for X, 1 for Y, 2 for Z
uniform float fish_axis_offset = 0.5; // Value to add to the selected vertex coordinate (e.g., if tail is at -1 on axis, this is 1.0)
uniform float fish_axis_length_inv = 0.5; // Inverse of fish length on the selected axis (e.g., if length is 2, this is 1.0/2.0 = 0.5)

uniform float mask_black = 0.5; // Point where mask starts to become black (towards head)
uniform float mask_white = 0.0; // Point where mask is fully white (towards tail)

// Varying for body was for debug, not strictly needed for animation itself
// varying float body_debug_var;

void vertex() {
	// Use animation_time_input directly, which is controlled (and paused) by the script
	float time = animation_time_input + (6.28318 * INSTANCE_CUSTOM.x);

	float coord;
	if (primary_axis == 0) { coord = VERTEX.x; }
	else if (primary_axis == 1) { coord = VERTEX.y; }
	else { coord = VERTEX.z; }

	float body = clamp((coord + fish_axis_offset) * fish_axis_length_inv, 0.0, 1.0);
	// body_debug_var = body; // No longer needed for final animation

	float mask = smoothstep(mask_black, mask_white, 1.0 - body);

	// --- Pivot Motion ---
	// Rotates the fish side-to-side around its center (world Y-axis assumed as 'up' for pivot)
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 pivot_rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	// If fish is along X or Z, pivot its XZ plane. If along Y, this would be a roll.
	// Assuming fish is not primarily aligned with Y for standard pivot.
    if (primary_axis == 0 || primary_axis == 2) { // Fish along X or Z
        VERTEX.xz = pivot_rotation_matrix * VERTEX.xz; 
    } else { // Fish along Y (pivot would be more like a roll on XZ plane)
        VERTEX.xz = pivot_rotation_matrix * VERTEX.xz; // Or adapt if Y-aligned fish needs different pivot plane
    }

	// --- Wave Motion ---
	// Sine wave along the body, masked. Applied perpendicular to the fish's length.
	float wave_val = cos(time + body * 3.0) * wave * 0.2 * mask;
	if (primary_axis == 0) { // Fish along X (e.g. X-forward, Y-up)
		VERTEX.z += wave_val; // Wave on Z-axis (side-to-side)
	} else if (primary_axis == 1) { // Fish along Y (e.g. Y-up, X-forward)
		VERTEX.x += wave_val; // Wave on X-axis (side-to-side)
	} else { // Fish along Z (default) (e.g. Z-forward, Y-up)
		VERTEX.x += wave_val; // Wave on X-axis (side-to-side)
	}

	// --- Twist Motion ---
	// Rolling motion along the fish's spine (primary_axis), masked.
	float twist_angle = cos(time + body * 2.5) * 0.3 * twist * mask;
	mat2 twist_rotation_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	
	if (primary_axis == 0) { // Fish along X, roll around X (affecting YZ plane)
		VERTEX.yz = mix(VERTEX.yz, twist_rotation_matrix * VERTEX.yz, mask);
	} else if (primary_axis == 1) { // Fish along Y, roll around Y (affecting XZ plane)
		VERTEX.xz = mix(VERTEX.xz, twist_rotation_matrix * VERTEX.xz, mask);
	} else { // Fish along Z (default), roll around Z (affecting XY plane)
		VERTEX.xy = mix(VERTEX.xy, twist_rotation_matrix * VERTEX.xy, mask);
	}
}

void fragment(){
	ALBEDO = texture(albedo_texture, UV).rgb;
	EMISSION = texture(emission_texture, UV).rgb * emission_energy;
} 