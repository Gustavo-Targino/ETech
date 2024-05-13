CREATE OR ALTER FUNCTION [dbo].[FNC_CalculaTotalPedido](@IdPedido INT)
	RETURNS DECIMAL(10,2)
AS
		/*
			Documentação
			Arquivo fonte.........: FNC_CalculaTotalPedido.sql
			Objetivo..............: Calcular o valor total de um determinado pedido
			Autor.................: Gustavo Targino
			Data..................: 07/05/2024
			Ex....................: BEGIN TRAN
										
										SELECT Id, 
											   ValorTotal 
											FROM Pedido
											WHERE Id = 4

										SELECT [dbo].[FNC_CalculaTotalPedido](4) ValorTotal
											
									ROLLBACK

		*/

	BEGIN

	RETURN (
		SELECT SUM((pt.Preco * pp.Quantidade)) ValorTotalCalculado
			FROM [dbo].[Pedido] pe
				INNER JOIN [dbo].[PedidoProduto] pp
					ON pp.IdPedido = pe.Id
				INNER JOIN [dbo].[Produto] pt
					ON pt.Id = pp.IdProduto
			WHERE pe.Id = @IdPedido
		)

	END