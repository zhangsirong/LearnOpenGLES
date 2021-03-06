precision highp float;

struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light {
    vec3 position;
    vec3 direction;
    float cutOff;//切角
    float outerCutOff;//外部圆锥切角 平滑边缘用到
    
    float constant;//衰减函数的3个系数
    float linear;
    float quadratic;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

varying mediump vec3 Normal;
varying mediump vec3 FragPos;
varying mediump vec2 TexCoords;

uniform vec3 viewPos;
uniform Material material;
uniform Light light;


void main(void) {
    
    vec3 lightDir = normalize(light.position - FragPos);
    float theta = dot(lightDir, normalize(-light.direction));

    vec3 result;
    if (theta > light.outerCutOff) {//在手电筒的照亮范围内 换成外角度了
        // Ambient 环境分量
        vec3 ambient = light.ambient * vec3(texture2D(material.diffuse, TexCoords));
        
        // Diffuse 漫反射分量
        vec3 norm = normalize(Normal);
        float diff = max(dot(norm, lightDir), 0.0);
        vec3 diffuse = light.diffuse * diff * vec3(texture2D(material.diffuse, TexCoords));
        
        //https://learnopengl-cn.github.io/02%20Lighting/05%20Light%20casters/
        // Specular 镜面分量
        vec3 viewDir = normalize(viewPos - FragPos);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        vec3 specular = light.specular * spec * vec3(texture2D(material.specular, TexCoords));
        
        // Spotlight 手电筒 (平滑边缘)
        float epsilon = (light.cutOff - light.outerCutOff);
        float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
        diffuse  *= intensity;
        specular *= intensity;
        
        // 衰减
        float distance    = length(light.position - FragPos);
        float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
        ambient  *= attenuation;
        diffuse  *= attenuation;
        specular *= attenuation;
        
        result = ambient + diffuse + specular;
        
    } else {// 否则使用环境光，使得场景不至于完全黑暗
        result = light.ambient * vec3(texture2D(material.diffuse, TexCoords));
    }


    gl_FragColor = vec4(result, 1.0);

}
