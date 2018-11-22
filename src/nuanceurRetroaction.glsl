#version 410

uniform vec3 bDim, posPuits;
uniform float temps, dt, tempsMax, gravite;

layout(location=6) in vec3 position;
layout(location=7) in vec4 couleur;
layout(location=8) in vec3 vitesse;
layout(location=9) in float tempsRestant;

out vec3 positionMod;
out vec4 couleurMod;
out vec3 vitesseMod;
out float tempsRestantMod;

uint randhash( uint seed ) // entre  0 et UINT_MAX
{
    uint i=(seed^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u);
    i *= 2654435769u;
    i += (i<<5u)^(i>>12u);
    return i;
}
float myrandom( uint seed ) // entre  0 et 1
{
    const float UINT_MAX = 4294967295.0;
    return float(randhash(seed)) / UINT_MAX;
}

void main( void )
{
    if ( tempsRestant <= 0.0 )
    {
        // se préparer à produire une valeur un peu aléatoire
        uint seed = uint(temps * 1000.0) + uint(gl_VertexID);
        // faire renaitre la particule au puits
        positionMod = posPuits;

        // assigner un vitesse
        vitesseMod = vec3( mix( -0.5, 0.5, myrandom(seed++) ),   // entre -0.5 et 0.5
                           mix( -0.5, 0.5, myrandom(seed++) ),   // entre -0.5 et 0.5
                           mix(  0.5, 1.0, myrandom(seed++) ) ); // entre  0.5 et 1

        // nouveau temps de vie
        //tempsRestantMod = ...; // entre 0 et tempsMax secondes
        tempsRestantMod = mix( 0., tempsMax, myrandom(seed++) );

        // interpolation linéaire entre COULMIN et COULMAX
        const float COULMIN = 0.2; // valeur minimale d'une composante de couleur lorsque la particule (re)naît
        const float COULMAX = 0.9; // valeur maximale d'une composante de couleur lorsque la particule (re)naît
        couleurMod = vec4( mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre -0.5 et 0.5
                           mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre -0.5 et 0.5
                           mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre  0.5 et 1
                           1.0 ); 
    }
    else
    {
        // avancer la particule (méthode de Euler)
        positionMod = position + dt * vitesse; // ...
        vitesseMod = vitesse;

        // diminuer son temps de vie
        tempsRestantMod = tempsRestant - dt;

        // garder la couleur courante
        couleurMod = couleur;

        // collision avec la demi-sphère ?
        vec3 posSphUnitaire = positionMod / bDim;
        vec3 vitSphUnitaire = vitesseMod * bDim;
        
        float  dist = length( posSphUnitaire );
		if ( dist  >= 1.0 ) // la  particule  est  sortie  de la  bulle
		{
			positionMod = ( 2.0 - dist ) * positionMod;
			vec3 N = posSphUnitaire / dist; //  normaliser N
			vec3  vitReflechieSphUnitaire = reflect( vitSphUnitaire , N );
			vitesseMod = vitReflechieSphUnitaire / bDim;
		}

        // collision avec le sol ?
        if ( positionMod.z  <= 0.0 ) // la  particule  est  sous la bulle
		{
			positionMod.z = ( - positionMod.z );
			vec3 N = vec3(0., 0., 1.); //  normaliser N
			vitesseMod = reflect( vitesseMod , N );
		}

        // appliquer la gravité
        vec3 g = gravite * vec3(0., 0., -1.0);
        vitesseMod += g * dt;
    }

    // Mettre un test bidon afin que l'optimisation du compilateur n'élimine pas les attributs dt, gravite, tempsMax posPuits et bDim.
    // Vous ENLEVEREZ cet énoncé inutile!
    if ( dt+bDim.x+gravite+tempsMax+posPuits.x < -100000 ) tempsRestantMod += .000001;
}
