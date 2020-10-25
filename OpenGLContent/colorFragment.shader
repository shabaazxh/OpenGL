#version 330 core
out vec4 FragColor;

struct Material{
    sampler2D diffuse;
    sampler2D specular;
    sampler2D emission;
    float shininess;
};

struct Light{
	vec3 position;
    vec3 direction;

    float constant;
    float linear;
    float quadratic;

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

uniform Light light;
uniform Material material;
uniform vec3 viewPos;

in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;


void main()
{


//Ambient

    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));

//Diffuse
/* Calculate the direction vetor between the light source and fragpos. Lights direction vector is the difference between lights position
and fragment position vector. Difference can be calculated by substracing both vectors. Ensure end up as unit vectors hence normalize */
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));

//Specular

    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess); /*Calculate dot product between view direction and reflect direction, make sure its not negative
    and then reaise to the power of 32. Higher the 32 number the shinier the object */
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));

    //attenuation
    float distance = length(light.position - FragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;

    //emission

    //vec3 emission = vec3(texture(material.emission, TexCoords));

    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0);
}


