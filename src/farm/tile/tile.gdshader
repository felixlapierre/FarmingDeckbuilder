shader_type canvas_item;
uniform vec2 push;

void vertex() {
	float mult = VERTEX.y / 16.0;
	VERTEX += push * vec2(mult, mult);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
