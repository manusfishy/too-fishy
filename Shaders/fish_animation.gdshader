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
uniform int primary_axis = 0; // 0=X, 1=Y, 2=Z
uniform float fish_axis_offset = 0.5; // Value to add to the selected vertex coordinate (e.g., if tail is at -1 on axis, this is 1.0)
uniform float fish_axis_length_inv = 0.5; // Inverse of fish length on the selected axis (e.g., if length is 2, this is 1.0/2.0 = 0.5)

uniform float mask_black = 0.5; // Point where mask starts to become black (towards head)
uniform float mask_white = 0.0; // Point where mask is fully white (towards tail)

// Varying for body was for debug, not strictly needed for animation itself
// varying float body_debug_var;

void vertex() {
	float time = animation_time_input + (TAU * INSTANCE_CUSTOM.x);

	// Select coordinate based on primary axis
	vec3 coords = vec3(VERTEX.x, VERTEX.y, VERTEX.z);
	float coord = coords[primary_axis];

	// Calculate body position (0 at tail, 1 at head)
	float body = clamp((coord + fish_axis_offset) * fish_axis_length_inv, 0.0, 1.0);
	
	// Mask for animation intensity (stronger at tail)
	float mask = smoothstep(mask_black, mask_white, 1.0 - body);

	// Pivot Motion - same for all orientations (rotates around Y-axis)
	float pivot_angle = cos(time) * 0.1 * pivot;
	float cos_pivot = cos(pivot_angle);
	float sin_pivot = sin(pivot_angle);
	mat2 pivot_matrix = mat2(vec2(cos_pivot, -sin_pivot), vec2(sin_pivot, cos_pivot));
	VERTEX.xz = pivot_matrix * VERTEX.xz;

	// Wave Motion - apply perpendicular to fish length
	float wave_val = cos(time + body * 3.0) * wave * 0.2 * mask;
	if (primary_axis == 0) {
		VERTEX.z += wave_val; // Fish along X, wave on Z
	} else if (primary_axis == 1) {
		VERTEX.x += wave_val; // Fish along Y, wave on X  
	} else {
		VERTEX.x += wave_val; // Fish along Z, wave on X
	}

	// Twist Motion - roll around the fish's spine
	float twist_angle = cos(time + body * 2.5) * 0.3 * twist * mask;
	float cos_twist = cos(twist_angle);
	float sin_twist = sin(twist_angle);
	mat2 twist_matrix = mat2(vec2(cos_twist, -sin_twist), vec2(sin_twist, cos_twist));
	
	if (primary_axis == 0) {
		VERTEX.yz = mix(VERTEX.yz, twist_matrix * VERTEX.yz, mask);
	} else if (primary_axis == 1) {
		VERTEX.xz = mix(VERTEX.xz, twist_matrix * VERTEX.xz, mask);
	} else {
		VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, mask);
	}
}

void fragment(){
	ALBEDO = texture(albedo_texture, UV).rgb;
	EMISSION = texture(emission_texture, UV).rgb * emission_energy;
} 