CREATE OR ALTER TRIGGER [dbo].[TRG_RastreioPedido]
	ON [dbo].[Rastreio]
	AFTER INSERT
AS
		/*	
			Documentação

			Arquivo fonte.........: TRG_RastreioPedido.sql
			Objetivo..............: Validar processamento após novo rastreio para um pedido
			Autor.................: Gustavo Targino
			Data..................: 07/05/2024
			Ex....................: BEGIN TRAN
					
										SELECT * FROM Produto
										SELECT * FROM Pedido WHERE Id = 4
										SELECT * FROM PedidoProduto WHERE IdPedido = 4
										SELECT * FROM Rastreio WHERE IdPedido = 4

										EXEC [dbo].[SP_CancelarPedido] 4
										
										SELECT * FROM Produto
										SELECT * FROM Pedido WHERE Id = 4
										SELECT * FROM PedidoProduto WHERE IdPedido = 4
										SELECT * FROM Rastreio WHERE IdPedido = 4

									ROLLBACK

		*/
		
	BEGIN
		DECLARE @IdPedido INT,
				@IdStatusRastreio TINYINT,
				@Quantidade INT,
				@IdProduto INT
				
		SELECT @IdPedido = IdPedido,
			   @IdStatusRastreio = IdStatusRastreio
			FROM INSERTED
			
		DECLARE ProdutosDoPedido CURSOR STATIC FOR 
			SELECT	pp.IdPedido,
					pp.IdProduto,
					pp.Quantidade
				FROM PedidoProduto pp WITH(NOLOCK)
				WHERE pp.IdPedido = @IdPedido

		IF @IdStatusRastreio = 4 -- Cancelado
			BEGIN
				OPEN ProdutosDoPedido
					FETCH NEXT FROM ProdutosDoPedido 
						INTO @IdPedido,
							 @IdProduto,
							 @Quantidade
				WHILE @@FETCH_STATUS = 0
					BEGIN
						EXEC [dbo].[SP_AtualizarEstoqueProduto]@IdProduto, @Quantidade

						FETCH NEXT FROM ProdutosDoPedido 
							INTO @IdPedido,
								 @IdProduto,
								 @Quantidade
					END
				CLOSE ProdutosDoPedido
				DEALLOCATE ProdutosDoPedido
				
			END

	END