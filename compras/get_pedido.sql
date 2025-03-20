SELECT
    compras_requisicoes.item AS cod_item,
    compras_requisicoes.comprador,
    compras_requisicoes.valor_sugerido AS valor_sugerido,
    compras_requisicoes.dados_auxiliares AS dados_aux,
    erp_itens.codigo AS cod_item_fluig,
    erp_unidades.descricao AS Un,
    erp_unidades.codigo AS codigo_unidade,
    compras_requisicoes.quantidade AS Qtd,
    compras_requisicoes.id_solicitacao AS fluig,
    erp_itens.descricao AS Descricao_prod,
    compras_requisicoes.id AS Requisicao,
    compras_requisicoes.especificacoes AS Especificacoes,
    compras_solicitacoes_cotacao.id AS Solicitacao,
    erp_depositos.id AS deposito,
    compras_pedidos_compra.status,
    COALESCE(compras_pedidos_compra.tipo, 1) AS Tipo,
    compras_tipo_compra.descricao AS tipo_descricao,
    compras_requisicoes.cotacao AS Cotacao,
    compras_requisicoes.justificativa_pedido AS justificativa_pedido,
    COALESCE(compras_cotacoes.contrato, 0) AS Contrato,
    compras_requisicoes.id_solicitacao AS codigo_integracao,
    COALESCE(compras_cotacoes_fornecedor.valor_unitario, 'NOK') AS V_Un,
    COALESCE(compras_cotacoes_fornecedor.imposto, 'NOK') AS Imp,
    COALESCE(compras_cotacoes_fornecedor_impostos.imposto, 'NOK') AS tipo_imposto,
    COALESCE(compras_cotacoes_fornecedor.adicionais_item, 'NOK') AS V_Adicionais,
    COALESCE(compras_cotacoes_adicionais_fornecedor.adicional, 'NOK') AS Desc_Adicional,
    compras_condicoes_pagamento.id AS id_codicao_pagamento,
    compras_condicoes_pagamento.codigo AS codigo_condicao,
    COALESCE(compras_condicoes_pagamento.descricao, 'NOK') AS Cond,
    COALESCE(compras_cotacoes_fornecedor.parcelas, 'NOK') AS Parc,
    COALESCE(compras_cotacoes_fornecedor.valor_parcela, 'NOK') AS V_Parc,
    COALESCE(compras_cotacoes_fornecedor.valor_total, 'NOK') AS V_Total,
    COALESCE(compras_cotacoes_fornecedor.sequencia, 'NOK') AS Seq,
    compras_pedidos_compra.comentario AS comentario_comprador,
    concat(usuario_comprador.nome, ' ', usuario_comprador.sobrenome) AS nome_comprador,
    erp_pessoas.nome_fantasia AS nome_fornecedor_escolhido,
    erp_pessoas.razao_social AS razao_social,
    erp_pessoas.cnpj_cpf AS cnpj_fornecedor_escolhido,
    compras_cotacoes_fornecedor_cabecalho.pessoa AS Id_fornecedor,
    compras_cotacoes_fornecedor_cabecalho.id AS Id_Cabecalho,
    compras_cotacoes_fornecedor_cabecalho.compra_direta AS C_Ditera,
    compras_cotacoes_fornecedor_cabecalho.cnpj AS CNPJ,
    compras_cotacoes_fornecedor_cabecalho.razao_social AS Razao_Social,
    compras_cotacoes_fornecedor_cabecalho.usuario AS Responsavel,
    compras_cotacoes_fornecedor_cabecalho.tipo_entrega AS Tipo_Entrega,
    CASE
        WHEN compras_cotacoes_fornecedor_cabecalho.compra_direta = TRUE
        THEN compras_cotacoes_fornecedor_cabecalho.pessoa_faturamento
        ELSE
            CASE
                WHEN compras_pedidos_compra.pessoa_faturamento IS NOT NULL
                THEN compras_pedidos_compra.pessoa_faturamento
                ELSE NULL
            END
    END AS pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.nome_fantasia, NULL) AS nome_fantasia_pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.cnpj_cpf, NULL) AS cnpj_pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.razao_social, NULL) AS razao_social_pessoa_faturamento,
    compras_tipos_entrega.tipo AS Desc_Tipo_Entrega,
    compras_pedidos_compra.percentual_adiantamento_pedido AS PercentualAdiantamentoPedido,
    compras_pedidos_compra.valor_adiantamento_pedido AS ValorAdiantamentoPedido,
    compras_tipos_entrega.codigo AS codigo_entrega,
    compras_cotacoes_fornecedor_cabecalho.frete AS Frete,
    DATE_FORMAT(compras_cotacoes_fornecedor_cabecalho.previsao_entrega, '%Y-%m-%d') AS Prev_Entrega,
    DATE_FORMAT(compras_cotacoes_fornecedor.data_previsao_entrega, '%Y-%m-%d') AS previsao_entrega_item,
    compras_cotacoes_fornecedor_cabecalho.observacao AS Obs_forne,
    erp_naturezas.id AS naturezas,
    erp_naturezas.codigo AS codigo_natureza,
    erp_naturezas.descricao AS nome_natureza,
    erp_categorias.codigo AS codigo_categoria,
    erp_categorias.descricao AS nome_categoria,
    erp_itens_tipo.codigo AS tipo_produto,
    erp_moeda.id AS id_moeda,
    erp_moeda.simbolo,
    erp_moeda.descricao AS sigla_moeda,
    (
        SELECT
            moon_usuarios.empresa
        FROM
            moon_usuarios
        INNER JOIN
            moon_usuario_pessoas ON moon_usuario_pessoas.usuario = moon_usuarios.id
        WHERE
            moon_usuario_pessoas.pessoa = compras_cotacoes_fornecedor_cabecalho.pessoa
        LIMIT 1
    ) AS moon_origem,
    COALESCE((
        SELECT
            TRUE
        FROM
            financeiro_itens_nota_fiscal
        WHERE
            requisicao = compras_requisicoes.id
        LIMIT 1
    ), FALSE) AS temNF
FROM
    compras_requisicoes
INNER JOIN
    moon_usuarios AS usuario_comprador ON usuario_comprador.id = compras_requisicoes.comprador
INNER JOIN
    compras_pedidos_compra ON compras_pedidos_compra.id = compras_requisicoes.pedido
INNER JOIN
    compras_tipo_compra ON compras_tipo_compra.id = compras_pedidos_compra.tipo
INNER JOIN
    erp_itens ON compras_requisicoes.item = erp_itens.id
INNER JOIN
    erp_unidades ON erp_itens.unidade = erp_unidades.id
LEFT JOIN
    erp_naturezas ON erp_naturezas.id = erp_itens.natureza
LEFT JOIN
    erp_categorias ON erp_categorias.id = erp_itens.categoria
LEFT JOIN
    erp_itens_tipo ON erp_itens_tipo.codigo = erp_itens.tipo
LEFT JOIN
    compras_solicitacoes_cotacao ON compras_requisicoes.cotacao = compras_solicitacoes_cotacao.cotacao
    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
LEFT JOIN
    compras_cotacoes_fornecedor ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
    AND compras_cotacoes_fornecedor.sequencia = (
        SELECT
            MAX(CCF.sequencia)
        FROM
            compras_cotacoes_fornecedor AS CCF
        WHERE
            CCF.solicitacao = compras_solicitacoes_cotacao.id
        LIMIT 1
    )
    AND compras_cotacoes_fornecedor.requisicao = compras_requisicoes.id
LEFT JOIN
    compras_cotacoes_fornecedor_impostos ON compras_cotacoes_fornecedor_impostos.cotacao_fornecedor = compras_cotacoes_fornecedor.id
LEFT JOIN
    compras_cotacoes_adicionais_fornecedor ON compras_cotacoes_adicionais_fornecedor.cotacao_fornecedor = compras_cotacoes_fornecedor.id
LEFT JOIN
    compras_cotacoes_fornecedor_cabecalho ON compras_requisicoes.cotacao = compras_cotacoes_fornecedor_cabecalho.cotacao
    AND compras_cotacoes_fornecedor_cabecalho.pessoa = compras_solicitacoes_cotacao.pessoa
LEFT JOIN
    compras_tipos_entrega ON compras_tipos_entrega.id = compras_cotacoes_fornecedor_cabecalho.tipo_entrega
INNER JOIN
    compras_condicoes_pagamento ON compras_cotacoes_fornecedor.condicao = compras_condicoes_pagamento.id
INNER JOIN
    compras_cotacoes ON compras_requisicoes.cotacao = compras_cotacoes.id
INNER JOIN
    erp_moeda ON compras_cotacoes.moeda = erp_moeda.id
INNER JOIN
    erp_pessoas ON erp_pessoas.id = compras_solicitacoes_cotacao.pessoa
INNER JOIN
    erp_depositos ON erp_depositos.id = compras_requisicoes.deposito
LEFT JOIN
    erp_pessoas AS erp_pessoa_compra_direta ON erp_pessoa_compra_direta.id = (
        CASE
            WHEN compras_pedidos_compra.pessoa_faturamento IS NOT NULL
            THEN compras_pedidos_compra.pessoa_faturamento
            ELSE
                CASE
                    WHEN compras_cotacoes_fornecedor_cabecalho.compra_direta = TRUE
                    THEN compras_cotacoes_fornecedor_cabecalho.pessoa_faturamento
                    ELSE NULL
                END
        END
    ) AND erp_pessoa_compra_direta.empresa_moon = compras_pedidos_compra.empresa_moon
WHERE
    compras_requisicoes.empresa_moon = 187
    AND compras_pedidos_compra.id = 6993
    AND (compras_requisicoes.status != 20 OR compras_pedidos_compra.status = 4)
GROUP BY
    Requisicao
UNION ALL
SELECT
    compras_requisicoes.item AS cod_item,
    compras_requisicoes.comprador,
    compras_requisicoes.valor_sugerido AS valor_sugerido,
    compras_requisicoes.dados_auxiliares AS dados_aux,
    erp_itens.codigo AS cod_item_fluig,
    erp_unidades.descricao AS Un,
    erp_unidades.codigo AS codigo_unidade,
    compras_requisicoes.quantidade AS Qtd,
    compras_requisicoes.id_solicitacao AS fluig,
    erp_itens.descricao AS Descricao_prod,
    compras_requisicoes.id AS Requisicao,
    compras_requisicoes.especificacoes AS Especificacoes,
    compras_solicitacoes_cotacao.id AS Solicitacao,
    erp_depositos.id AS deposito,
    compras_pedidos_compra.status,
    COALESCE(compras_pedidos_compra.tipo, 1) AS Tipo,
    compras_tipo_compra.descricao AS tipo_descricao,
    compras_pedidos_cancelados.cotacao AS Cotacao,
    compras_requisicoes.justificativa_pedido AS justificativa_pedido,
    COALESCE(compras_cotacoes.contrato, 0) AS Contrato,
    compras_requisicoes.id_solicitacao AS codigo_integracao,
    COALESCE(compras_cotacoes_fornecedor.valor_unitario, 'NOK') AS V_Un,
    COALESCE(compras_cotacoes_fornecedor.imposto, 'NOK') AS Imp,
    COALESCE(compras_cotacoes_fornecedor_impostos.imposto, 'NOK') AS tipo_imposto,
    COALESCE(compras_cotacoes_fornecedor.adicionais_item, 'NOK') AS V_Adicionais,
    COALESCE(compras_cotacoes_adicionais_fornecedor.adicional, 'NOK') AS Desc_Adicional,
    compras_condicoes_pagamento.id AS id_codicao_pagamento,
    compras_condicoes_pagamento.codigo AS codigo_condicao,
    COALESCE(compras_condicoes_pagamento.descricao, 'NOK') AS Cond,
    COALESCE(compras_cotacoes_fornecedor.parcelas, 'NOK') AS Parc,
    COALESCE(compras_cotacoes_fornecedor.valor_parcela, 'NOK') AS V_Parc,
    COALESCE(compras_cotacoes_fornecedor.valor_total, 'NOK') AS V_Total,
    COALESCE(compras_cotacoes_fornecedor.sequencia, 'NOK') AS Seq,
    compras_pedidos_compra.comentario AS comentario_comprador,
    concat(usuario_comprador.nome, ' ', usuario_comprador.sobrenome) AS nome_comprador,
    erp_pessoas.nome_fantasia AS nome_fornecedor_escolhido,
    erp_pessoas.razao_social AS razao_social,
    erp_pessoas.cnpj_cpf AS cnpj_fornecedor_escolhido,
    compras_cotacoes_fornecedor_cabecalho.pessoa AS Id_fornecedor,
    compras_cotacoes_fornecedor_cabecalho.id AS Id_Cabecalho,
    compras_cotacoes_fornecedor_cabecalho.compra_direta AS C_Ditera,
    compras_cotacoes_fornecedor_cabecalho.cnpj AS CNPJ,
    compras_cotacoes_fornecedor_cabecalho.razao_social AS Razao_Social,
    compras_cotacoes_fornecedor_cabecalho.usuario AS Responsavel,
    compras_cotacoes_fornecedor_cabecalho.tipo_entrega AS Tipo_Entrega,
    CASE
        WHEN compras_cotacoes_fornecedor_cabecalho.compra_direta = TRUE
        THEN compras_cotacoes_fornecedor_cabecalho.pessoa_faturamento
        ELSE
            CASE
                WHEN compras_pedidos_compra.pessoa_faturamento IS NOT NULL
                THEN compras_pedidos_compra.pessoa_faturamento
                ELSE NULL
            END
    END AS pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.nome_fantasia, NULL) AS nome_fantasia_pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.cnpj_cpf, NULL) AS cnpj_pessoa_faturamento,
    COALESCE(erp_pessoa_compra_direta.razao_social, NULL) AS razao_social_pessoa_faturamento,
    compras_tipos_entrega.tipo AS Desc_Tipo_Entrega,
    compras_pedidos_compra.percentual_adiantamento_pedido AS PercentualAdiantamentoPedido,
    compras_pedidos_compra.valor_adiantamento_pedido AS ValorAdiantamentoPedido,
    compras_tipos_entrega.codigo AS codigo_entrega,
    compras_cotacoes_fornecedor_cabecalho.frete AS Frete,
    DATE_FORMAT(compras_cotacoes_fornecedor_cabecalho.previsao_entrega, '%Y-%m-%d') AS Prev_Entrega,
    DATE_FORMAT(compras_cotacoes_fornecedor.data_previsao_entrega, '%Y-%m-%d') AS previsao_entrega_item,
    compras_cotacoes_fornecedor_cabecalho.observacao AS Obs_forne,
    erp_naturezas.id AS naturezas,
    erp_naturezas.codigo AS codigo_natureza,
    erp_naturezas.descricao AS nome_natureza,
    erp_categorias.codigo AS codigo_categoria,
    erp_categorias.descricao AS nome_categoria,
    erp_itens_tipo.codigo AS tipo_produto,
    erp_moeda.id AS id_moeda,
    erp_moeda.simbolo,
    erp_moeda.descricao AS sigla_moeda,
    (
        SELECT
            moon_usuarios.empresa
        FROM
            moon_usuarios
        INNER JOIN
            moon_usuario_pessoas ON moon_usuario_pessoas.usuario = moon_usuarios.id
        WHERE
            moon_usuario_pessoas.pessoa = compras_cotacoes_fornecedor_cabecalho.pessoa
        LIMIT 1
    ) AS moon_origem,
    COALESCE((
        SELECT
            TRUE
        FROM
            financeiro_itens_nota_fiscal
        WHERE
            requisicao = compras_requisicoes.id
        LIMIT 1
    ), FALSE) AS temNF
FROM
    compras_requisicoes
INNER JOIN
    moon_usuarios AS usuario_comprador ON usuario_comprador.id = compras_requisicoes.comprador
INNER JOIN
    compras_pedidos_cancelados ON compras_pedidos_cancelados.requisicao = compras_requisicoes.id
INNER JOIN
    compras_pedidos_compra ON compras_pedidos_compra.id = compras_pedidos_cancelados.pedido
INNER JOIN
    compras_tipo_compra ON compras_tipo_compra.id = compras_pedidos_compra.tipo
INNER JOIN
    erp_itens ON compras_requisicoes.item = erp_itens.id
INNER JOIN
    erp_unidades ON erp_itens.unidade = erp_unidades.id
LEFT JOIN
    erp_naturezas ON erp_naturezas.id = erp_itens.natureza
LEFT JOIN
    erp_categorias ON erp_categorias.id = erp_itens.categoria
LEFT JOIN
    erp_itens_tipo ON erp_itens_tipo.codigo = erp_itens.tipo
LEFT JOIN
    compras_solicitacoes_cotacao ON compras_pedidos_cancelados.cotacao = compras_solicitacoes_cotacao.cotacao
    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
LEFT JOIN
    compras_cotacoes_fornecedor ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
    AND compras_cotacoes_fornecedor.sequencia = (
        SELECT
            MAX(CCF.sequencia)
        FROM
            compras_cotacoes_fornecedor AS CCF
        WHERE
            CCF.solicitacao = compras_solicitacoes_cotacao.id
        LIMIT 1
    )
    AND compras_cotacoes_fornecedor.requisicao = compras_pedidos_cancelados.requisicao
LEFT JOIN
    compras_cotacoes_fornecedor_impostos ON compras_cotacoes_fornecedor_impostos.cotacao_fornecedor = compras_cotacoes_fornecedor.id
LEFT JOIN
    compras_cotacoes_adicionais_fornecedor ON compras_cotacoes_adicionais_fornecedor.cotacao_fornecedor = compras_cotacoes_fornecedor.id
LEFT JOIN
    compras_cotacoes_fornecedor_cabecalho ON compras_pedidos_cancelados.cotacao = compras_cotacoes_fornecedor_cabecalho.cotacao
    AND compras_cotacoes_fornecedor_cabecalho.pessoa = compras_solicitacoes_cotacao.pessoa
LEFT JOIN
    compras_tipos_entrega ON compras_tipos_entrega.id = compras_cotacoes_fornecedor_cabecalho.tipo_entrega
INNER JOIN
    compras_condicoes_pagamento ON compras_cotacoes_fornecedor.condicao = compras_condicoes_pagamento.id
INNER JOIN
    compras_cotacoes ON compras_pedidos_cancelados.cotacao = compras_cotacoes.id
INNER JOIN
    erp_moeda ON compras_cotacoes.moeda = erp_moeda.id
INNER JOIN
    erp_pessoas ON erp_pessoas.id = compras_solicitacoes_cotacao.pessoa
INNER JOIN
    erp_depositos ON erp_depositos.id = compras_requisicoes.deposito
LEFT JOIN
    erp_pessoas AS erp_pessoa_compra_direta ON erp_pessoa_compra_direta.id = (
        CASE
            WHEN compras_pedidos_compra.pessoa_faturamento IS NOT NULL
            THEN compras_pedidos_compra.pessoa_faturamento
            ELSE
                CASE
                    WHEN compras_cotacoes_fornecedor_cabecalho.compra_direta = TRUE
                    THEN compras_cotacoes_fornecedor_cabecalho.pessoa_faturamento
                    ELSE NULL
                END
        END
    ) AND erp_pessoa_compra_direta.empresa_moon = compras_pedidos_compra.empresa_moon
WHERE
    compras_requisicoes.empresa_moon = 187
    AND compras_pedidos_compra.id = 6993
    AND compras_requisicoes.status != 20
GROUP BY
    Requisicao