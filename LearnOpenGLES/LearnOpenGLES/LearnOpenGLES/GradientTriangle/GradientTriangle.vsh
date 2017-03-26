attribute vec3 sourceColor;
attribute vec3 position;

varying mediump vec3 ourColor;

uniform mediump float xOffset;

void main(void) {
    
    ourColor = sourceColor;

    gl_Position = vec4(position,1.0);
//    gl_Position = vec4(position.x, -position.y, position.z, 1.0);
//    gl_Position = vec4(position.x + xOffset, position.y, position.z, 1.0);

}
