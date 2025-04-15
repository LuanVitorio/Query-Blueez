SELECT
    compras_solicitacoes_cotacao.id AS solicitacao,
    compras_solicitacoes_cotacao.cotacao AS cotacao,
    compras_requisicoes.id AS requisicao,
    erp_itens.descricao AS item,
    erp_itens.id AS id_item,
    erp_itens.tipo AS tipo_item,
    erp_itens.codigo AS codigo,
    compras_requisicoes.quantidade AS qtd,
    erp_empresas.id AS empresa,
    erp_empresas.nome_fantasia AS nome_empresa,
    compras_cotacoes_fornecedor.valor_unitario,
    compras_cotacoes_fornecedor.valor_total AS vl_total,
    compras_cotacoes_fornecedor.imposto AS imposto,
    compras_cotacoes_fornecedor.id AS id_cotacao_fornecedor,
    compras_cotacoes_fornecedor.percentual_adiantamento AS percentual_adiantamento,
    erp_pessoas.id AS id_forne,
    erp_pessoas.cnpj_cpf AS cnpj_cpf,
    erp_pessoas.nome_fantasia AS nome_forne,
    erp_pessoas.estado AS sigla_estado,
    compras_cotacoes_fornecedor.sequencia AS seq,
    erp_moeda.simbolo,
    erp_moeda.descricao AS sigla_moeda,
    compras_cotacoes_fornecedor_cabecalho.frete,
    COALESCE(DATE_FORMAT(compras_cotacoes.prazo_entrega, '%d/%m/%Y'), '--/--/----') AS prazo_entrega,
    COALESCE(DATE_FORMAT(compras_cotacoes_fornecedor.data_previsao_entrega, '%d/%m/%Y'), '--/--/----') AS data_entrega_previsao,
    compras_condicoes_pagamento.codigo AS codigo_condicao,
    compras_condicoes_pagamento.descricao AS condicao,
    compras_requisicoes.deposito AS deposito,
    compras_cotacoes_adicionais_fornecedor.valor_adicional AS adicionais,
    ROUND((compras_cotacoes_adicionais_fornecedor.valor_adicional * compras_requisicoes.quantidade), 2) AS total_adicionais,
    compras_cotacoes.contrato AS contrato,
    JSON_OBJECTAGG(
        COALESCE(compras_cotacoes_especificacoes.especificacao, 'NULL'),
        COALESCE(compras_cotacoes_especificacoes.valor_especificacao, '')
    ) AS especificacoes_cotacao,
    compras_requisicoes.id_solicitacao_filho AS id_solicitacao_edicao_requisicao,
    flow_etapas.tipo AS tipo_etapa_edicao_requisicao
FROM compras_solicitacoes_cotacao
INNER JOIN compras_cotacoes ON compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
INNER JOIN erp_pessoas ON compras_solicitacoes_cotacao.pessoa = erp_pessoas.id
INNER JOIN compras_requisicoes ON compras_cotacoes.id = compras_requisicoes.cotacao
INNER JOIN erp_empresas ON erp_empresas.id = compras_requisicoes.empresa

-- Adicione essa cláusula se houver restrição de estabelecimentos:
-- AND erp_empresas.id IN (1, 2, 3)

-- Adicione essa cláusula se houver restrição de projetos:
-- INNER JOIN erp_projetos ON erp_projetos.id = compras_requisicoes.projeto
-- AND erp_projetos.id IN (4, 5, 6)

INNER JOIN erp_itens ON compras_requisicoes.item = erp_itens.id
INNER JOIN compras_cotacoes_fornecedor
    ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
    AND compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
    AND compras_cotacoes_fornecedor.sequencia = (
        SELECT MAX(CCF.sequencia)
        FROM compras_cotacoes_fornecedor AS CCF
        WHERE CCF.solicitacao = compras_solicitacoes_cotacao.id
        LIMIT 1
    )
LEFT JOIN compras_cotacoes_adicionais_fornecedor
    ON compras_solicitacoes_cotacao.id = compras_cotacoes_adicionais_fornecedor.cotacao_fornecedor
    AND compras_cotacoes_adicionais_fornecedor.sequencia = compras_cotacoes_fornecedor.sequencia
    AND compras_cotacoes_adicionais_fornecedor.requisicao = compras_requisicoes.id
INNER JOIN erp_moeda ON compras_cotacoes.moeda = erp_moeda.id
INNER JOIN compras_cotacoes_fornecedor_cabecalho
    ON compras_cotacoes.id = compras_cotacoes_fornecedor_cabecalho.cotacao
    AND compras_cotacoes_fornecedor_cabecalho.pessoa = compras_solicitacoes_cotacao.pessoa
INNER JOIN compras_condicoes_pagamento ON compras_cotacoes_fornecedor.condicao = compras_condicoes_pagamento.id
LEFT JOIN compras_cotacoes_especificacoes
    ON compras_cotacoes_especificacoes.cotacao = compras_cotacoes.id
    AND compras_cotacoes_especificacoes.pessoa = compras_solicitacoes_cotacao.pessoa
    AND compras_cotacoes_especificacoes.sequencia = compras_cotacoes_fornecedor.sequencia
    AND compras_cotacoes_especificacoes.item = erp_itens.id
LEFT JOIN flow_solicitacoes ON flow_solicitacoes.id = compras_requisicoes.id_solicitacao_filho
LEFT JOIN flow_etapas ON flow_etapas.id = flow_solicitacoes.etapa_atual
WHERE compras_solicitacoes_cotacao.empresa_moon = 187
  AND compras_solicitacoes_cotacao.status = 2
  AND compras_requisicoes.status != 3
  AND compras_requisicoes.pedido IS NULL
  AND compras_cotacoes_fornecedor.declinado = 0
  AND compras_requisicoes.comprador = (select id from moon_usuarios where login = "roberto.santos@blueezdemonstracao.com.br")

-- Adicione filtros opcionais abaixo conforme necessário:
-- AND compras_solicitacoes_cotacao.pessoa = ?
-- AND compras_solicitacoes_cotacao.cotacao = ?
-- AND compras_requisicoes.empresa = ?
-- AND erp_pessoas.cnpj_cpf = ?
-- AND erp_itens.codigo = ?

GROUP BY compras_cotacoes_fornecedor.id
ORDER BY solicitacao;