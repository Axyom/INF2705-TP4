#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

uniform float pointsize;

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;
layout(location=4) in vec3 vitesse;
layout(location=5) in float tempsRestant;

out Attribs {
    vec4 couleur;
    float tempsRestant;
    float sens; // du vol
} AttribsOut;

void main( void )
{
    // transformation standard du sommet
    gl_Position = matrVisu * matrModel * Vertex;

    AttribsOut.tempsRestant = tempsRestant;

    // couleur du sommet
    AttribsOut.couleur = Color;

    // assigner la taille des points (en pixels)
    gl_PointSize = pointsize;

	vec3 v_visu = mat3(matrVisu * matrModel) * vitesse;
	AttribsOut.sens = sign(v_visu.x);
}
