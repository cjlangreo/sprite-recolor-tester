shader_type canvas_item;

uniform vec3 color : source_color = vec3(1,1,1);

void fragment() {
  COLOR.rgb *= color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
