CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizaPrecoPedido_QuantidadeProduto]
	ON [dbo].[PedidoProduto]
	FOR INSERT, DELETE
AS
		/*
			Documentação
			Arquivo Fonte........: TRG_AtualizaPrecoPedido_QuantidadeProduto.sql
			Objetivo.............: Atualizar estoque do produto e valor total do pedido após inserção ou remoção de um novo produto no pedido
			Autor................: Gustavo Targino
			Data.................: 06/05/2024
			Ex...................: BEGIN TRAN
									
										DECLARE @IdPedido INT
									
										INSERT INTO Pedido VALUES(1, GETDATE(), 0)

										SET @IdPedido = SCOPE_IDENTITY()

										SELECT * FROM PedidoProduto
										SELECT * FROM Pedido
										SELECT * FROM Produto

										EXEC [dbo].[SP_InsereProdutoPedido]@IdPedido, 1, 10

										EXEC [dbo].[SP_InsereProdutoPedido]@IdPedido, 1, 5
							
										SELECT * FROM PedidoProduto
										SELECT * FROM Pedido
										SELECT * FROM Produto

										DELETE FROM PedidoProduto WHERE IdPedido = @IdPedido AND IdProduto = 1 AND Quantidade = 5

										SELECT * FROM PedidoProduto
										SELECT * FROM Pedido
										SELECT * FROM Produto

								   ROLLBACK
		*/
	BEGIN
		DECLARE @IdPedido INT,
				@IdProduto INT,
				@Quantidade INT,
				@Insert BIT,
				@Preco DECIMAL(8,2),
				@Estoque INT

		SELECT @IdPedido = IdPedido,
				@IdProduto = IdProduto,
				@Quantidade = Quantidade,
				@Insert = 1
			FROM INSERTED

		IF EXISTS ( SELECT TOP 1 1 
							FROM DELETED )
				SELECT @IdPedido = IdPedido,
					   @IdProduto = IdProduto,
					   @Quantidade = Quantidade,
					   @Insert = 0
					FROM DELETED
		
		SET @Preco = @Quantidade * ( SELECT Preco * ( CASE 
														WHEN @Insert = 1 
															THEN  1 
															ELSE -1 
													  END) 
										FROM Produto WITH(NOLOCK) 
										WHERE Id = @IdProduto)

		SET @Quantidade = @Quantidade * ( CASE 
											WHEN @Insert = 1 
												THEN -1 
												ELSE  1 
										  END) 

		UPDATE Pedido 
			SET ValorTotal = ( ValorTotal + @Preco)
				WHERE Id = @IdPedido

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RAISERROR('Erro ao atualizar valor total do pedido ao adicionar produto', 16, 1);

		EXEC [dbo].[SP_AtualizarEstoqueProduto]@IdProduto, @Quantidade

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RAISERROR('Erro ao atualizar estoque do produto', 16, 1);

	END
