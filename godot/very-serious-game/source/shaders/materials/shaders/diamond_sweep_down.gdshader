shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform float progress : hint_range(0.0, 1.0, 0.001);
uniform float size = 40;
uniform bool fill = true;

void fragment() {
	// split the grid horizontally and vertically
	//into segments that are size fragments wide
	// and are offset to fill from the center
	float x = abs(fract(FRAGCOORD.x / size) - 0.5);
	float y = abs(fract(FRAGCOORD.y / size) - 0.5);
	
	// restrict the fill to the area between the
	// corners of each grid axis, which is a diamond
	// shape, because "x + y < z" defines a right
	// triangle, which is mirrored by using ABS above
	if (x + y + UV.y > progress * 2.0) {
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
