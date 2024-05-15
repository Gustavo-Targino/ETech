CREATE OR ALTER PROCEDURE [dbo].[SP_TotalPedidosCliente]
	@IdCliente INT = NULL
AS
		/*
			Documentação
			Arquivo fonte.........: Cliente.sql
			Objetivo..............: Listar o total dos pedidos de todos ou de apenas um cliente
			Autor.................: Gustavo Targino
			Data..................: 15/05
			Ex....................: BEGIN TRAN

										DECLARE @DataInicio DATETIME = GETDATE()

										EXEC [dbo].[SP_TotalPedidosCliente] 4

										SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo

									ROLLBACK
		*/
	BEGIN
		
		SELECT c.Id,
			   c.Nome,
			   c.Email,
			   COUNT(p.Id) 'Número de pedidos',
			   CONCAT('R$', SUM(p.ValorTotal)) Total
			FROM [dbo].[Cliente] c WITH(NOLOCK)
				INNER JOIN [dbo].[Pedido] p WITH(NOLOCK)
					ON p.IdCliente = c.Id
			WHERE c.Id = ISNULL(@IdCliente, c.Id)
			GROUP BY c.Nome, c.Email, c.Id

	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_PedidosCliente]
	@IdCliente INT
AS
		/*
			Documentação
			Arquivo fonte.........: Cliente.sql
			Objetivo..............: Listar os pedidos de um cliente
			Autor.................: Gustavo Targino
			Data..................: 15/05/2024
			Ex....................: BEGIN TRAN

										DECLARE @DataInicio DATETIME = GETDATE(),
												@Ret INT

										EXEC @Ret = [dbo].[SP_PedidosCliente] 2

										SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo,
											  @Ret Retorno

									ROLLBACK
			Retornos..............: 0 - Resultados retornados
									1 - Este cliente não existe
		*/
	BEGIN
		
		IF NOT EXISTS (
						 SELECT TOP 1 1
							FROM [dbo].[Cliente] c WITH(NOLOCK)
								WHERE c.Id = @IdCliente
					  )
			RETURN 1

		SELECT c.Id,
			   c.Nome,
			   c.Email,
			   p.Id Pedido,
			   STRING_AGG(pr.Nome, ', ') 'Itens do pedido',
			   CONCAT('R$', p.ValorTotal) Valor,
			   p.DataPedido
			FROM [dbo].[Cliente] c WITH(NOLOCK)
				INNER JOIN [dbo].[Pedido] p WITH(NOLOCK)
					ON p.IdCliente = c.Id
				INNER JOIN [dbo].[PedidoProduto] pp
					ON pp.IdPedido = p.Id
				INNER JOIN [dbo].[Produto] pr
					ON pp.IdProduto = pr.Id
			WHERE c.Id = @IdCliente
			GROUP BY c.Id,
					 c.Nome,
					 c.Email,
					 p.Id,
					 p.ValorTotal,
					 p.DataPedido

		RETURN 0
		
	END