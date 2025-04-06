shader_type spatial;

uniform float scale = 0.2;
uniform float speed = 1.0;
uniform float temperature = 1.0;
uniform float brightness = 1.0;
uniform sampler2D noise_tex;

varying vec2 uv;

float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

void vertex() {
	uv = (MODEL_MATRIX * vec4(VERTEX, 1)).xy;
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float t = 0.1 * TIME;
	vec2 v0 = vec2(0, t*2.0) * speed;
	vec2 v1 = vec2(0, t*0.1) * speed;
	float h0 = texture(noise_tex, uv * scale + v0).r;
	float h1 = texture(noise_tex, (uv * scale + v1 * 1.23) * 0.4).r;
	float h = h0 * h1;
	h = pow(h, 1.5);
	
	float hue = mix(0.0, 0.18, min(h*temperature, 1.0));
	float val = 1.0;
	float sat = 1.0;
	vec3 c = hsv2rgb(vec3(hue, sat, val));
	
	float border = 1.0;
	c *= border;
	vec2 model_scale = vec2(MODEL_MATRIX[0][0], MODEL_MATRIX[1][1]);
	vec2 model_translation = vec2(MODEL_MATRIX[3][0], MODEL_MATRIX[3][1]);
	float l = -sdRoundedBox(model_translation - uv, model_scale * 0.5, vec4(min(1.0, 0.5*min(model_scale.x, model_scale.y))));

	c *= brightness;
	ALBEDO = c;
	ALPHA = smoothstep(0.0, 0.1, l-h);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
