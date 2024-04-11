shader_type canvas_item;

uniform vec2 intersecting_x;
uniform vec2 intersecting_y;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	if (UV.x >= intersecting_x.x && UV.x <= intersecting_x.y &&
			UV.y >= intersecting_y.x && UV.y <= intersecting_y.y) {
		COLOR.a = 0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
