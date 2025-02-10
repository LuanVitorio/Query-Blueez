SELECT 
    contratos_tipos.id AS tipo_contrato,
    contratos_contratos.codigo,
    contratos_contratos.descricao,
    compras_condicoes_pagamento.descricao AS condicao_pagamento,
    DATE_FORMAT(contratos_contratos.periodo_inicio, '%d/%m/%Y') AS inicio_contrato,
    DATE_FORMAT(contratos_contratos.periodo_fim, '%d/%m/%Y') AS fim_contrato,
    contratos_contratos.vencimentos,
    contratos_contratos.valor_total AS valor_total_previsto,
    erp_empresas.nome_fantasia AS nome_empresa,
    erp_estabelecimento.nome_fantasia AS nome_estabelecimento,
    erp_pessoas.codigo AS codigo_fornecedor,
    erp_pessoas.nome_fantasia AS fornecedor,
    GROUP_CONCAT(DISTINCT erp_projetos.descricao SEPARATOR ',') AS grupo,
    erp_itens.codigo AS codigo_item,
    erp_itens.descricao AS descricao_item,
    SUM(contratos_itens_medicao.valor) AS valor_total_medido,
    SUM(contratos_medicoes.total_descontos) AS valor_total_desconto,
    contratos_contratos.indice,
    IF(contratos_controles.exigir_aprovacao_parcelas, 'true', 'false') AS exige_aprovacao_parcela,
    IF(contratos_controles.exigir_validacao_fornecedor, 'true', 'false') AS exige_validacao_fornecedor,
    IF(contratos_controles.travar_quando_saldo_atingido, 'true', 'false') AS travar_saldo_atingido,
    IF(contratos_controles.travar_valor_parcela, 'true', 'false') AS travar_valor_parcela,
    IF(contratos_controles.permite_aditivo, 'true', 'false') AS permite_aditivo,
    IF(contratos_alertas.vencimento_contrato, 'true', 'false') AS alerta_vencimento_contrato,
    IF(contratos_alertas.vencimento_parcela, 'true', 'false') AS alerta_vencimento_parcela,
    contratos_status.descricao AS status_contrato,
    IF(contratos_contratos.aprovado, 'true', 'false') AS aprovado,
    IF(contratos_contratos.ativo, 'true', 'false') AS ativo,
    IF(contratos_contratos.excluido, 'true', 'false') AS excluido,
    DATE_FORMAT(contratos_contratos.data_criacao, '%d/%m/%Y') AS data_criacao,
    moon_usuarios.nome AS nome_usuario_criacao,
    moon_usuarios.sobrenome AS sobrenome_usuario_criacao
FROM contratos_contratos
INNER JOIN contratos_controles ON contratos_controles.contrato = contratos_contratos.id
INNER JOIN contratos_alertas ON contratos_alertas.contrato = contratos_contratos.id
INNER JOIN contratos_partes ON contratos_partes.contrato = contratos_contratos.id
INNER JOIN erp_pessoas ON erp_pessoas.id = contratos_partes.pessoa
INNER JOIN contratos_empresas ON contratos_empresas.contrato = contratos_contratos.id
INNER JOIN erp_empresas ON erp_empresas.id = contratos_empresas.empresa
INNER JOIN erp_empresas AS erp_estabelecimento ON erp_estabelecimento.id = contratos_empresas.estabelecimento
LEFT JOIN contratos_contratos AS contrato_pai ON contrato_pai.id = contratos_contratos.pai
LEFT JOIN contratos_tipos ON contratos_tipos.id = contratos_contratos.tipo
INNER JOIN compras_condicoes_pagamento ON compras_condicoes_pagamento.id = contratos_contratos.condicao_pagamento
INNER JOIN moon_usuarios ON moon_usuarios.id = contratos_contratos.usuario_criacao
INNER JOIN contratos_status ON contratos_status.id = contratos_contratos.status
INNER JOIN contratos_itens ON contratos_itens.contrato = contratos_contratos.id
INNER JOIN erp_itens ON erp_itens.id = contratos_itens.item
LEFT JOIN contratos_medicoes ON contratos_medicoes.contrato = contratos_contratos.id
    AND contratos_medicoes.empresa = erp_empresas.id
    AND contratos_medicoes.status IN (1, 3, 5)
LEFT JOIN contratos_itens_medicao ON contratos_itens_medicao.medicao = contratos_medicoes.id
    AND contratos_itens_medicao.item = contratos_itens.id
LEFT JOIN contratos_projetos ON contratos_projetos.contrato = contratos_contratos.id
LEFT JOIN erp_projetos ON erp_projetos.id = contratos_projetos.projeto
WHERE 1 = 1
    AND contratos_contratos.ativo = ?
    AND contratos_contratos.empresa_moon = ?
    AND (contratos_contratos.tipo = ? OR contratos_contratos.tipo = ?)
GROUP BY contratos_contratos.id;
