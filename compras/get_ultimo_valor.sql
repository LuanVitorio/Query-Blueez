SELECT 
    compras_cotacoes_fornecedor.valor_unitario AS ultimo_valor
FROM 
    compras_cotacoes_fornecedor
INNER JOIN 
    compras_requisicoes ON compras_requisicoes.id = compras_cotacoes_fornecedor.requisicao
INNER JOIN 
    compras_solicitacoes_cotacao ON compras_solicitacoes_cotacao.id = compras_cotacoes_fornecedor.solicitacao
INNER JOIN 
    compras_pedidos_compra ON compras_pedidos_compra.id = compras_requisicoes.pedido
WHERE 
    compras_requisicoes.empresa_moon = 187
    AND compras_requisicoes.item =  146837
    AND compras_requisicoes.pedido IS NOT NULL
    AND compras_cotacoes_fornecedor.declinado = 0
ORDER BY 
    compras_requisicoes.pedido DESC, 
    compras_cotacoes_fornecedor.sequencia DESC, 
    compras_cotacoes_fornecedor.valor_unitario DESC
LIMIT 1;
