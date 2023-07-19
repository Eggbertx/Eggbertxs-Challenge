shader_type canvas_item;

uniform vec3 key = vec3(1.0, 0.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if(COLOR.rgb == key)
		COLOR.a = 0.0;
}