#version 410

uniform sampler2D laTexture;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

void main( void )
{
	FragColor = AttribsIn.couleur;

    // doit-on utiliser la texture?
    if ( texnumero != 0 )
    {
        vec4 couleurTex = texture( laTexture, AttribsIn.texCoord );
        FragColor.rgb = mix( AttribsIn.couleur.rgb, couleurTex.rgb, 0.7 );
        FragColor.a = couleurTex.a;
    }
    
    if (FragColor.a < 0.1)
		discard;
}
