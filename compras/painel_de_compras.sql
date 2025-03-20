SELECT
    compra_direta,
    fornecedor_direto,
    comprador,
    fluig,
    requisicao,
    data_solicitacao,
    data_emissao_pedido,
    data_aprovacao_pedido,
    unidade_medida,
    nome_empresa,
    codigo_deposito,
    nome_deposito,
    dados_auxiliares,
    codigo_item,
    quantidade,
    descricao_item,
    codigo_produto,
    categoria,
    requisitante,
    natureza,
    status_requisicao,
    cotacao,
    status_cotacao,
    pedido,
    tipo,
    data_criacao_req,
    data_criacao_cot,
    data_criacao_ped,
    frete,
    status_pedido,
    resumo,
    detalhe_item,
    fluig_pedido,
    cnpj_fornecedor,
    CASE
        WHEN (compra_direta = 0) THEN fornecedor
        ELSE fornecedor_direto
    END AS fornecedor,
    data_entrega_ped,
    numero_nf,
    fluig_nf,
    status_nf,
    valor_total_com_frete,
    valor_unitario,
    (valor_total_pedido + frete) AS valor_total_pedido,
    IFNULL(saving1, 0) AS saving1,
    IFNULL(saving2, 0) AS saving2,
    IFNULL(saving_cotacao_inicial, 0) AS saving_cotacao_inicial,
    IFNULL(saving_cotacao_final, 0) AS saving_cotacao_final,
    IFNULL(saving_pedido_fornecedor_inicial, 0) AS saving_pedido_fornecedor_inicial,
    IFNULL(saving_pedido_fornecedor_final, 0) AS saving_pedido_fornecedor_final,
    IFNULL(saving_pedido_cotacao_inicial, 0) AS saving_pedido_cotacao_inicial,
    IFNULL(saving_pedido_cotacao_final, 0) AS saving_pedido_cotacao_final,
    IFNULL(saving3_inicial, 0) AS saving3_inicial,
    IFNULL(saving3_final, 0) AS saving3_final,
    valor_sugerido,
    simbolo,
    lancamento_nf,
    data_pagamento,
    motivo_recusa,
    decimais,
    (
        SELECT
            ccf.valor_unitario
        FROM
            compras_cotacoes_fornecedor ccf
        INNER JOIN compras_requisicoes cr ON cr.id = ccf.requisicao
        WHERE
            cr.empresa_moon = 187
            AND cr.item = sub.codigo_item
            AND cr.pedido < sub.pedido
            AND ccf.declinado = 0
            AND sub.status_pedido NOT IN (1, 19, 6, 8)
        ORDER BY
            cr.pedido DESC,
            ccf.sequencia DESC,
            ccf.valor_unitario ASC
        LIMIT 1
    ) AS ultimo_valor
FROM
    (
        SELECT
            CONCAT(moon_usuarios.nome, " ", moon_usuarios.nome) AS comprador,
            CASE
                WHEN (compras_cotacoes_fornecedor_cabecalho.compra_direta IS NULL OR compras_cotacoes_fornecedor_cabecalho.compra_direta = 0) THEN 0
                ELSE 1
            END compra_direta,
            compras_cotacoes_fornecedor_cabecalho.razao_social AS fornecedor_direto,
            erp_unidades.codigo AS unidade_medida,
            erp_empresas.nome_fantasia AS nome_empresa,
            erp_depositos.codigo AS codigo_deposito,
            erp_depositos.descricao AS nome_deposito,
            compras_requisicoes.dados_auxiliares,
            compras_requisicoes.id_solicitacao AS fluig,
            compras_requisicoes.id AS requisicao,
            compras_requisicoes.item AS codigo_item,
            compras_requisicoes.quantidade,
            compras_requisicoes.valor_sugerido,
            erp_itens.descricao AS descricao_item,
            erp_itens.codigo AS codigo_produto,
            erp_categorias.descricao AS categoria,
            compras_requisicoes.nome_solicitante AS requisitante,
            IFNULL(erp_naturezas.descricao, ' ') AS natureza,
            COALESCE(compras_requisicoes_status_traducao.texto, compras_requisicoes_status.descricao) AS status_requisicao,
            compras_requisicoes.cotacao,
            COALESCE(compras_solicitacoes_cotacao_status_traducao.texto, compras_solicitacoes_cotacao_status.descricao) AS status_cotacao,
            compras_requisicoes.pedido,
            compras_requisicoes.motivo_recusa,
            compras_tipo_compra.descricao AS tipo,
            COALESCE(DATE_FORMAT(compras_requisicoes.data_solicitacao, '%d/%m/%Y %T'), '') AS data_solicitacao,
            COALESCE(DATE_FORMAT(compras_requisicoes.data_criacao, '%d/%m/%Y %T'), '') AS data_criacao_req,
            COALESCE(DATE_FORMAT(compras_cotacoes.data_criacao, '%d/%m/%Y %T'), '') AS data_criacao_cot,
            COALESCE(DATE_FORMAT(compras_pedidos_compra.data_criacao, '%d/%m/%Y %T'), '') AS data_criacao_ped,
            COALESCE(DATE_FORMAT(compras_pedidos_compra.data_emissao, '%d/%m/%Y %T'), '') AS data_emissao_pedido,
            COALESCE(DATE_FORMAT(compras_pedidos_compra.data_aprovacao, '%d/%m/%Y %T'), '') AS data_aprovacao_pedido,
            COALESCE(FORMAT(compras_cotacoes_fornecedor_cabecalho.frete, 2), '') AS frete,
            COALESCE(compras_pedidos_compra_status_traducao.texto, compras_pedidos_compra_status.descricao) AS status_pedido,
            flow_solicitacoes.resumo AS resumo,
            compras_requisicoes.especificacoes AS detalhe_item,
            compras_pedidos_compra.codigo_integracao AS fluig_pedido,
            erp_pessoas.nome_fantasia AS fornecedor,
            erp_pessoas.cnpj_cpf AS cnpj_fornecedor,
            COALESCE(DATE_FORMAT(compras_requisicoes.data_recebimento, '%d/%m/%Y %T'), '') AS data_entrega_ped,
            COALESCE(
                (
                    SELECT
                        financeiro_notas_fiscais.numero_nf
                    FROM
                        financeiro_notas_fiscais
                    LEFT JOIN financeiro_itens_nota_fiscal ON financeiro_itens_nota_fiscal.nota_fiscal = financeiro_notas_fiscais.id
                    WHERE
                        financeiro_itens_nota_fiscal.requisicao = compras_requisicoes.id
                    ORDER BY
                        financeiro_notas_fiscais.id DESC
                    LIMIT 1
                ),
                NULL
            ) AS numero_nf,
            COALESCE(
                (
                    SELECT
                        COALESCE(financeiro_nota_fiscal_status_traducao.texto, financeiro_nota_fiscal_status.descricao) AS descricao
                    FROM
                        financeiro_notas_fiscais
                    INNER JOIN financeiro_nota_fiscal_status ON financeiro_nota_fiscal_status.id = financeiro_notas_fiscais.status
                    LEFT JOIN financeiro_nota_fiscal_status_traducao ON financeiro_nota_fiscal_status_traducao.status = financeiro_nota_fiscal_status.id
                    AND financeiro_nota_fiscal_status_traducao.lingua = 1
                    LEFT JOIN financeiro_itens_nota_fiscal ON financeiro_itens_nota_fiscal.nota_fiscal = financeiro_notas_fiscais.id
                    WHERE
                        financeiro_itens_nota_fiscal.requisicao = compras_requisicoes.id
                    ORDER BY
                        financeiro_notas_fiscais.id DESC
                    LIMIT 1
                ),
                NULL
            ) AS status_nf,
            COALESCE(
                (
                    SELECT
                        financeiro_notas_fiscais.codigo_integracao
                    FROM
                        financeiro_notas_fiscais
                    LEFT JOIN financeiro_itens_nota_fiscal ON financeiro_itens_nota_fiscal.nota_fiscal = financeiro_notas_fiscais.id
                    WHERE
                        financeiro_itens_nota_fiscal.requisicao = compras_requisicoes.id
                    ORDER BY
                        financeiro_notas_fiscais.id DESC
                    LIMIT 1
                ),
                NULL
            ) AS fluig_nf,
            COALESCE(
                (
                    SELECT
                        COALESCE(DATE_FORMAT(data_criacao_registro, '%d/%m/%Y %T'), '')
                    FROM
                        financeiro_notas_fiscais
                    LEFT JOIN financeiro_itens_nota_fiscal ON financeiro_itens_nota_fiscal.nota_fiscal = financeiro_notas_fiscais.id
                    WHERE
                        financeiro_itens_nota_fiscal.requisicao = compras_requisicoes.id
                    ORDER BY
                        financeiro_notas_fiscais.id DESC
                    LIMIT 1
                ),
                NULL
            ) AS lancamento_nf,
            COALESCE(
                (
                    SELECT
                        COALESCE(DATE_FORMAT(data_pagamento, '%d/%m/%Y'), '')
                    FROM
                        financeiro_notas_fiscais
                    LEFT JOIN financeiro_itens_nota_fiscal ON financeiro_itens_nota_fiscal.nota_fiscal = financeiro_notas_fiscais.id
                    WHERE
                        financeiro_itens_nota_fiscal.requisicao = compras_requisicoes.id
                    ORDER BY
                        financeiro_notas_fiscais.id DESC
                    LIMIT 1
                ),
                NULL
            ) AS data_pagamento,
            COALESCE(FORMAT(compras_cotacoes_fornecedor.valor_total + compras_cotacoes_fornecedor_cabecalho.frete, 2), '') AS valor_total_com_frete,
            compras_cotacoes_fornecedor.valor_unitario AS valor_unitario,
            compras_cotacoes_fornecedor.decimais,
            (
                SELECT
                    compras_cotacoes_fornecedor.valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                WHERE
                    compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
                    AND compras_cotacoes_fornecedor.requisicao = compras_requisicoes.id
                    AND compras_cotacoes_fornecedor.sequencia = (
                        SELECT
                            MIN(sequencia)
                        FROM
                            compras_cotacoes_fornecedor
                        WHERE
                            solicitacao = compras_solicitacoes_cotacao.id
                    )
                    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
                LIMIT 1
            ) AS saving1,
            (
                SELECT
                    MIN(compras_cotacoes_fornecedor.valor_total)
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                WHERE
                    compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
                    AND compras_cotacoes_fornecedor.requisicao = compras_requisicoes.id
                    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
                LIMIT 1
            ) AS saving2,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                WHERE
                    compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
                    AND compras_cotacoes_fornecedor.solicitacao = compras_solicitacoes_cotacao.id
                    AND compras_cotacoes_fornecedor.sequencia = 1
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_cotacao_inicial,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                WHERE
                    compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
                    AND compras_cotacoes_fornecedor.solicitacao = compras_solicitacoes_cotacao.id
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa,
                    compras_cotacoes_fornecedor.sequencia
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_cotacao_final,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_cotacoes_fornecedor.sequencia = 1
                    AND compras_solicitacoes_cotacao.status <> 3
                    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_pedido_fornecedor_inicial,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_solicitacoes_cotacao.status <> 3
                    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa,
                    compras_cotacoes_fornecedor.sequencia
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_pedido_fornecedor_final,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_cotacoes_fornecedor.sequencia = 1
                    AND compras_solicitacoes_cotacao.status <> 3
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_pedido_cotacao_inicial,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_solicitacoes_cotacao.status <> 3
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa,
                    compras_cotacoes_fornecedor.sequencia
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving_pedido_cotacao_final,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_cotacoes_fornecedor.sequencia = 1
                    AND compras_solicitacoes_cotacao.status <> 3
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving3_inicial,
            (
                SELECT
                    SUM(compras_cotacoes_fornecedor.valor_total) AS valor_total
                FROM
                    compras_cotacoes_fornecedor
                INNER JOIN compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
                INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                WHERE
                    compras_requisicoes.pedido = compras_pedidos_compra.id
                    AND compras_solicitacoes_cotacao.status <> 3
                    AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
                GROUP BY
                    compras_solicitacoes_cotacao.pessoa,
                    compras_cotacoes_fornecedor.sequencia
                ORDER BY
                    valor_total
                LIMIT 1
            ) AS saving3_final,
            COALESCE(
                (
                    SELECT
                        SUM(valor_total)
                    FROM
                        (
                            SELECT
                                compras_requisicoes.pedido,
                                compras_cotacoes_fornecedor.valor_total
                            FROM
                                compras_cotacoes_fornecedor
                            INNER JOIN compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
                            GROUP BY
                                compras_cotacoes_fornecedor.requisicao
                        ) AS valor_total
                    WHERE
                        valor_total.pedido = compras_requisicoes.pedido
                    GROUP BY
                        compras_requisicoes.pedido
                ),
                NULL
            ) AS valor_total_pedido,
            erp_moeda.simbolo
        FROM
            compras_requisicoes
        INNER JOIN erp_empresas ON erp_empresas.id = compras_requisicoes.empresa
        LEFT JOIN moon_usuarios ON moon_usuarios.id = compras_requisicoes.comprador
        LEFT JOIN flow_solicitacoes ON flow_solicitacoes.id = compras_requisicoes.id_solicitacao
        INNER JOIN erp_itens ON erp_itens.id = compras_requisicoes.item
        LEFT JOIN erp_categorias ON erp_categorias.id = erp_itens.categoria
        INNER JOIN erp_unidades ON erp_unidades.id = erp_itens.unidade
        INNER JOIN erp_depositos ON erp_depositos.id = compras_requisicoes.deposito
        LEFT JOIN erp_naturezas ON erp_naturezas.id = erp_itens.natureza
        INNER JOIN compras_requisicoes_status ON compras_requisicoes_status.id = compras_requisicoes.status
        LEFT JOIN compras_requisicoes_status_traducao ON compras_requisicoes_status_traducao.status = compras_requisicoes.status
        AND compras_requisicoes_status_traducao.lingua = 1
        LEFT JOIN compras_cotacoes ON compras_cotacoes.id = compras_requisicoes.cotacao
        LEFT JOIN compras_solicitacoes_cotacao_status ON compras_solicitacoes_cotacao_status.id = compras_cotacoes.status
        LEFT JOIN compras_solicitacoes_cotacao_status_traducao ON compras_solicitacoes_cotacao_status_traducao.status = compras_cotacoes.status
        AND compras_solicitacoes_cotacao_status_traducao.lingua = 1
        LEFT JOIN compras_pedidos_compra ON compras_pedidos_compra.id = compras_requisicoes.pedido
        LEFT JOIN compras_pedidos_compra_status ON compras_pedidos_compra_status.id = compras_pedidos_compra.status
        LEFT JOIN compras_pedidos_compra_status_traducao ON compras_pedidos_compra_status_traducao.status = compras_pedidos_compra.status
        AND compras_pedidos_compra_status_traducao.lingua = 1
        LEFT JOIN compras_tipo_compra ON compras_tipo_compra.id = compras_pedidos_compra.tipo
        LEFT JOIN compras_solicitacoes_cotacao ON (
            compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
            AND compras_requisicoes.pedido IS NULL
        )
        OR (
            compras_solicitacoes_cotacao.cotacao = compras_cotacoes.id
            AND compras_solicitacoes_cotacao.pessoa = compras_pedidos_compra.pessoa
        )
        LEFT JOIN compras_cotacoes_fornecedor ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
        AND compras_cotacoes_fornecedor.requisicao = compras_requisicoes.id
        AND compras_cotacoes_fornecedor.sequencia = (
            SELECT
                MAX(CCF.sequencia)
            FROM
                compras_cotacoes_fornecedor AS CCF
            WHERE
                CCF.solicitacao = compras_solicitacoes_cotacao.id
            LIMIT 1
        )
        LEFT JOIN compras_cotacoes_fornecedor_cabecalho ON compras_cotacoes_fornecedor_cabecalho.cotacao = compras_cotacoes.id
        AND compras_cotacoes_fornecedor_cabecalho.pessoa = compras_pedidos_compra.pessoa
        LEFT JOIN erp_pessoas ON erp_pessoas.id = compras_pedidos_compra.pessoa
        LEFT JOIN erp_moeda ON erp_moeda.id = compras_cotacoes.moeda
        WHERE
            compras_requisicoes.empresa_moon = 187
            AND compras_requisicoes.data_criacao >= STR_TO_DATE('01/03/2025', '%d/%m/%Y')

        ORDER BY
            VALOR_UNITARIO DESC
    ) AS sub
GROUP BY
    sub.requisicao;