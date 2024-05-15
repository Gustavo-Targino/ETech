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

									EXEC @Ret = [dbo].[SP_RealizaPedido]2, 4
									
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

									SELECT * FROM Pedido
									SELECT * FROM PedidoProduto

									EXEC @Ret = [dbo].[SP_InsereProdutoPedido]@IdPedido, 1, 10
							
									SELECT * FROM Pedido
									SELECT * FROM PedidoProduto

									EXEC @Ret = [dbo].[SP_InsereProdutoPedido]@IdPedido, 1, 10
							
									SELECT * FROM Pedido
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
							FROM Pedido WITH(NOLOCK)
								WHERE Id = @IdPedido
								AND DATEDIFF(HOUR, DataPedido, GETDATE()) <= 24
					  )
			RETURN 1
			
		IF @Quantidade < 0
			RETURN 2

		IF @Quantidade > ISNULL([dbo].[FNC_VerificaEstoqueProduto](@IdProduto), 0)
			RETURN 3
			
		IF EXISTS ( 
					SELECT TOP 1 1 
						FROM PedidoProduto WITH(NOLOCK)
							WHERE IdProduto = @IdProduto
							AND IdPedido = @IdPedido
				  )
	
			UPDATE [dbo].[PedidoProduto]
				SET Quantidade = Quantidade + @Quantidade
					WHERE IdPedido = @IdPedido
					AND IdProduto = @IdProduto

		ELSE
			INSERT INTO [dbo].[PedidoProduto] (IdPedido, IdProduto, Quantidade)
					VALUES (@IdPedido, @IdProduto, @Quantidade)
						
	
		IF @@ERROR <> 0 
			RETURN 4


		RETURN 0
	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluiProdutoPedido]
	@IdPedido INT,
	@IdProduto INT,
	@Quantidade INT
AS
		/*
			Documentação
			Arquivo fonte.....: Pedido.sql
			Objetivo..........: Excluir produto para pedido feito, até 24h após realização do pedido
			Autor.............: Gustavo Targino
			Data..............: 07/05/2024
			Ex................: BEGIN TRAN
									
									DECLARE @Ret INT,
											@IdPedido INT
									
									SELECT @IdPedido = MAX(IdPedido) FROM PedidoProduto
									
									SELECT * FROM PedidoProduto

									EXEC @Ret = [dbo].[SP_ExcluiProdutoPedido]@IdPedido, 1, 5
							
									SELECT * FROM PedidoProduto

									SELECT @Ret Retorno

								ROLLBACK
			Retornos..........: 0 - Produto inserido no pedido
								1 - Este pedido não existe ou não está elegível para remover produtos
								2 - Quantidade que deseja ser removida excede a quantidade atual do produto
								3 - Erro ao excluir produto do pedido
								4 - Erro ao atualizar quantidade do produto no pedido 
		*/

	BEGIN
		
		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM Pedido WITH(NOLOCK)
								WHERE Id = @IdPedido
								AND DATEDIFF(HOUR, DataPedido, GETDATE()) <= 24
					  )
			RETURN 1
			
		IF @Quantidade > (
							SELECT Quantidade
								FROM PedidoProduto pp WITH(NOLOCK)
									WHERE pp.IdPedido = @IdPedido
									AND pp.IdProduto = @IdProduto
						 )
			RETURN 2

		IF @Quantidade = (
							SELECT Quantidade
								FROM PedidoProduto pp WITH(NOLOCK)
									WHERE pp.IdPedido = @IdPedido
									AND pp.IdProduto = @IdProduto
						 )
			BEGIN
				DELETE FROM [dbo].[PedidoProduto] 
					WHERE IdPedido = @IdPedido
					AND IdProduto = @IdProduto
				RETURN 0
			END
		
		IF @@ERROR <> 0 
			RETURN 3

		UPDATE [dbo].[PedidoProduto]
			SET Quantidade = Quantidade - @Quantidade
				WHERE IdPedido = @IdPedido
				AND IdProduto = @IdProduto

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 4

		RETURN 0
	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_CancelarPedido]
	@IdPedido INT
AS
		/*
			Documentação
				Arquivo fonte.........: Pedido.sql
				Objetivo..............: Cancelar um pedido
				Autor.................: Gustavo Targino
				Data..................: 07/05/2024
				Ex....................: BEGIN TRAN
											
											DECLARE @Ret INT

											SELECT * FROM Rastreio WHERE IdPedido = 4
											SELECT * FROM Produto

											EXEC @Ret = [dbo].[SP_CancelarPedido] 4

											SELECT * FROM Pedido 
											SELECT * FROM Rastreio WHERE IdPedido = 4
											SELECT * FROM Produto

											SELECT @Ret Retorno

										ROLLBACK

				Retornos..............: 0 - Pedido cancelado com sucesso
										1 - Esse pedido não existe
										2 - Status do Rastreio atual do pedido não permite cancelamento
										3 - Erro ao inserir nova fase do rastreio para o pedido
			
		*/

	BEGIN
		DECLARE @DataAtual DATETIME = GETDATE(),
				@StatusRastreio INT

		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM Pedido p WITH(NOLOCK)
							WHERE p.Id = @IdPedido
					  )
			RETURN 1

		SELECT @StatusRastreio = r.IdStatusRastreio 
			FROM Pedido p WITH(NOLOCK)
				INNER JOIN Rastreio r WITH(NOLOCK)
					ON r.IdPedido = p.Id
			WHERE r.Data <= @DataAtual 
			AND p.Id = @IdPedido
			
		IF @StatusRastreio IN (2, 3, 4, 5)
			RETURN 2

		-- IdStatusRastreio 4 = Cancelado
		INSERT INTO [dbo].[Rastreio] (IdPedido, IdStatusRastreio, Data)
			VALUES (@IdPedido, 4, GETDATE())

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 3

		RETURN 0

	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_HistoricoRastreio]
	@IdPedido INT
AS
		/*
			Documentação
			Arquivo fonte.....: Pedido.sql
			Objetivo..........: Listar o histórico de rastreio de um pedido
			Autor.............: Gustavo Targino
			Data..............: 15/05/2024
			Ex................: BEGIN TRAN

									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DataInicio DATETIME = GETDATE(),
											@Ret INT
										
									EXEC @Ret = [dbo].[SP_HistoricoRastreio] 50
									
									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo,
										@Ret Retorno
										
								ROLLBACK
			Retornos..........: 0 - Dados retornados
								1 - Esse pedido não existe
		*/
	BEGIN
		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM [dbo].[Pedido] p WITH(NOLOCK)
								WHERE p.Id = @IdPedido
					  )
			RETURN 1

		SELECT p.Id,
			   sr.Nome Status,
			   r.Data
			FROM [dbo].[Rastreio] r WITH(NOLOCK)
				INNER JOIN [dbo].[StatusRastreio] sr WITH(NOLOCK)
					ON sr.Id = r.IdStatusRastreio
				INNER JOIN [dbo].[Pedido] p WITH(NOLOCK)
					ON p.Id = r.IdPedido
			WHERE p.Id = @IdPedido
			ORDER BY r.Data DESC
	END