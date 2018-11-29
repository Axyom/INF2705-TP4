#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform int texnumero;

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

in Attribs {
    vec4 couleur;
    float tempsRestant;
    float sens; // du vol
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

void main()
{
    vec2 coins[4];
    float angle = 6*AttribsIn[0].tempsRestant;
    angle *= AttribsIn[0].sens;
	mat2 texRot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
    coins[0] = vec2( -0.5,  0.5 );
    coins[1] = vec2( -0.5, -0.5 );
    coins[2] = vec2(  0.5,  0.5 );
    coins[3] = vec2(  0.5, -0.5 );
    for ( int i = 0 ; i < 4 ; ++i )
    {
        float fact = gl_in[0].gl_PointSize / 25;
        vec2 decalage = coins[i]; // on positionne successivement aux quatre coins
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        gl_Position = matrProj * pos;    // on termine la transformation débutée dans le nuanceur de sommets

        AttribsOut.couleur = AttribsIn[0].couleur;
        
        if (texnumero == 1)
        {
			AttribsOut.texCoord = texRot*coins[i] + vec2( 0.5, 0.5 ); // on utilise coins[] pour définir des coordonnées de texture	
		}
		else if (texnumero == 2 || texnumero == 3)
		{
			AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 );
			AttribsOut.texCoord.x /= 16.0; // on divise par le nombre de sprites
			AttribsOut.texCoord.x +=  int(18 *AttribsIn[0].tempsRestant)/16.0;
			AttribsOut.texCoord.x *= AttribsIn[0].sens;
		}
		else
        {
			AttribsOut.texCoord = (coins[i] + vec2( 0.5, 0.5 )); // on utilise coins[] pour définir des coordonnées de texture
		}
        
        EmitVertex();
    }
}
