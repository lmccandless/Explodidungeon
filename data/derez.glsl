#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main(void) {
  vec2 tc4 = vertTexCoord.st;//vec2(0,0);
  
  int q = int(gl_FragCoord.st.x) % 2;
  if (q >0 ) tc4 -= vec2(texOffset.s*q,0);
  q = int(gl_FragCoord.st.y) % 2;
  if (q >0 ) tc4 -= vec2(0,texOffset.t*q);
  

  //  vec2 tc4 = vertTexCoord.st;
    vec4 col0 = texture2D(texture, tc4);
	
	//col0 =+ texture2D(texture, tc4 + vec2(texOffset.s,0));
	//col0 =+ texture2D(texture, tc4 + vec2(0,texOffset.t));
	//col0 =+ texture2D(texture, tc4 + vec2(texOffset.s,texOffset.t));
	//col0 *= 0.5;
	gl_FragColor = col0;  
   
}
