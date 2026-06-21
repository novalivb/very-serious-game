shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform float progress : hint_range(0.0, 1.0, 0.001);
uniform sampler2D _shape : source_color;
uniform bool fill = true;
uniform vec2 center_offset = vec2(0.3, 0.3);

void fragment() {
	vec2 uv_offset = vec2(0.5, 0.5);
	vec2 translated_uv = vec2(uv_offset.x + center_offset.x, uv_offset.y + center_offset.y);
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 aspect_offset = vec2(translated_uv.x * aspect, translated_uv.y);
	vec2 aspect_uv = vec2(UV.x * aspect, UV.y);
	vec2 offset_uv = aspect_uv - aspect_offset;
	vec2 scaled_uv = offset_uv / ((1.0 - progress) * 12.0);
	vec2 recentered_uv = scaled_uv + uv_offset;
	
	float shape = texture(_shape, recentered_uv).b;//vec2(((UV.x - 0.5) / progress / 2.0) + 0.5, ((UV.y - 0.5) / progress / 2.0) + 0.5)).r;
	
	if (shape > 0.0) {
		if (fill){
			discard;
		}
	}else if (!fill){
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
