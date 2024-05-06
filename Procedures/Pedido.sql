CREATE OR ALTER PROCEDURE [dbo].[SP_RealizaPedido]
	@IdCliente INT,
	@IdEnderecoCliente INT
AS
		/* 
			Documentação
			Arquivo fonte.......: Pedido.sql
			Objetivo............: Procedure para realizar um pedido
			Autor...............: Gustavo Targino
			Data................: 06/05/2024
			Ex..................: BEGIN TRAN
										
									DECLARE @Ret INT,
											@Inicio DATETIME = GETDATE()

									SELECT * FROM Pedido
									SELECT * FROM Rastreio

									EXEC @Ret = [dbo].[SP_RealizaPedido]1, 1
									
									SELECT * FROM Pedido
									SELECT * FROM Rastreio

									SELECT @Ret Retorno

								  ROLLBACK

			Retornos............: 0 - Pedido inserido com sucesso.
								  1 - Cliente ou endereço não existem ou este cliente não possui este endereço.
								  2 - Erro ao inserir pedido.
								  3 - Erro ao atribuir rastreio.
		*/	
	BEGIN
	
		DECLARE @IdPedidoInserido INT,
				@DataAtual DATETIME = GETDATE()

		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[FNC_ListaEnderecoCliente](@IdCliente) ec
									WHERE ec.IdEndereco = @IdEnderecoCliente
						)
			RETURN 1

		INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal)
					VALUES (@IdCliente, @DataAtual, 0)

		SET @IdPedidoInserido = SCOPE_IDENTITY()

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 2

		-- IdStatusRastreio 7 = Aguardando produtos
		INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data)
					VALUES (@IdPedidoInserido, 7, @DataAtual)

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 3

		RETURN 0

	END

GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InsereProdutoPedido]
	@IdPedido INT,
	@IdProduto INT,
	@Quantidade INT
AS
		/*
			Documenta��o
			Arquivo fonte.....: Pedido.sql
			Objetivo..........: Adicionar produto para pedido feito, até 24h após realização do pedido
			Autor.............: Gustavo Targino
			Data..............: 06/05/2024
			Ex................: BEGIN TRAN
									
									DECLARE @Ret INT,
											@IdPedido INT
									
									INSERT INTO Pedido VALUES(1, GETDATE(), 0)

									SET @IdPedido = SCOPE_IDENTITY()

									SELECT * FROM PedidoProduto

									EXEC @Ret = [dbo].[SP_InsereProdutoPedido]@IdPedido, 1, 10
							
									SELECT * FROM PedidoProduto

									SELECT @Ret Retorno

								ROLLBACK
			Retornos..........: 0 - Produto inserido no pedido
								1 - Este pedido não existe ou não está elegível para adicionar produtos
								2 - Quantidade não pode ser negativo
								3 - Quantidade do pedido maior do que estoque ou produto inexistente
								4 - Erro ao inserir produto no pedido 

		*/

	BEGIN
		
		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM Pedido
								WHERE Id = @IdPedido
								AND DATEDIFF(HOUR, DataPedido, GETDATE()) <= 24
					  )
			RETURN 1
			
		IF @Quantidade < 1
			RETURN 2

		IF @Quantidade > ISNULL([dbo].[FNC_VerificaEstoqueProduto](@IdProduto), 0)
			RETURN 3

		INSERT INTO [dbo].[PedidoProduto] (IdPedido, IdProduto, Quantidade)
				VALUES (@IdPedido, @IdProduto, @Quantidade)
						 
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 4

		RETURN 0
	END