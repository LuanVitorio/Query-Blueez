INSERT INTO moon_parametros_empresas (empresa_moon, parametro, ativo)
SELECT moon_empresas.id,
       parametro.id,
       b'1'
FROM moon_empresas
CROSS JOIN (SELECT id FROM moon_parametros WHERE codigo = '{{insira seu parametro aqui}}') parametro
LEFT JOIN moon_parametros_empresas ON moon_parametros_empresas.empresa_moon = moon_empresas.id 
                                       AND moon_parametros_empresas.parametro = parametro.id
WHERE moon_parametros_empresas.empresa_moon IS NULL;