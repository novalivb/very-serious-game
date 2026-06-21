shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform float progress : hint_range(0.0, 1.0, 0.001);
uniform bool fill = true;

void fragment() {
	// Called for every pixel the material is visible on.
	if (abs(UV.x) > progress) {
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
