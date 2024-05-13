CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarEstoqueProduto]
	@IdProduto INT,
	@Quantidade INT
AS
		/*
			Documentação
			Arquivo fonte.......: Produto.sql
			Objetivo............: Atualizar o estoque de um produto
			Autor...............: Gustavo Targino
			Data................: 07/05/2024
			Ex..................: BEGIN TRAN
									
									SELECT * FROM Produto WHERE Id = 1

									EXEC [dbo].[SP_AtualizarEstoqueProduto]1, 10

									SELECT * FROM Produto WHERE Id = 1

								  ROLLBACK
			Retornos............: 0 - Sucesso ao atualizar o estoque do produto
								  1 - Erro ao atualizar o estoque do produto

		*/
	BEGIN

		UPDATE Produto
				SET Estoque = Estoque + @Quantidade
					WHERE Id = @IdProduto

		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			RETURN 1

		RETURN 0

	END

GO
CREATE OR ALTER PROCEDURE [dbo].[SP_InserirProduto]
	@IdFornecedor INT,
	@Nome VARCHAR(100),
	@Preco DECIMAL(8,2),
	@Descricao VARCHAR(255),
	@EstoqueInicial INT,
	@UsuarioCadastro INT,
	@DataCadastro DATE
AS
		/*
			Documentação
			Arquivo fonte.......: Produto.sql
			Objetivo............: Inserir produto
			Autor...............: Gustavo Targino
			Data................: 07/05/2024
			Ex..................: BEGIN TRAN
									
									DECLARE @DataInicio DATE = GETDATE(),
											@Ret INT

									SELECT * FROM Produto

									EXEC @Ret = [dbo].[SP_InserirProduto]4, 'Kit Mouse e Teclado Microsoft', 200, 'Kit de Mouse e Teclado Wireless da Microsoft', 15, 4, @DataInicio

									SELECT * FROM Produto 
									SELECT @Ret

								  ROLLBACK
			Retornos............: 0 - Sucesso ao inserir produto e gerar estoque inicial
								  1 - Este produto já existe
								  2 - Não é possível inserir produto com preço negativo
								  3 - Não é possível inserir produto com estoque negativo
								  4 - Erro ao inserir produto
								  5 - Erro ao inserir pedido do produto para fornecedor

		*/

	BEGIN
		DECLARE @PrecoCompra DECIMAL(7,2),
				@IdProdutoInserido INT,
				@Ret INT

		-- Checar se este produto já existe
		IF EXISTS (
					SELECT TOP 1 1
						FROM [dbo].[Produto]
							WHERE Nome LIKE @Nome
				  )
			RETURN 1
				
		IF @Preco < 0
			RETURN 2

		-- Checar se EstoqueInicial é menor que 0
		IF @EstoqueInicial < 0
			RETURN 3

		BEGIN TRANSACTION
			-- Inserir produto
			BEGIN TRY
				INSERT INTO [dbo].[Produto] (Nome, Preco, Descricao, Estoque, UsuarioCadastro, DataCadastro)
				VALUES (@Nome, @Preco, @Descricao, @EstoqueInicial, @UsuarioCadastro, @DataCadastro)

				SET @IdProdutoInserido = SCOPE_IDENTITY()
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 4
			END CATCH

			EXEC @Ret = [dbo].[SP_GerarProdutoFornecedor] @IdFornecedor, @IdProdutoInserido, @EstoqueInicial, NULL

			IF @Ret <> 0
				BEGIN
					ROLLBACK TRANSACTION
					RETURN 5
				END

		COMMIT TRANSACTION

	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GerarProdutoFornecedor]
	@IdFornecedor INT,
	@IdProduto INT,
	@Quantidade INT,
	@PrecoCompra DECIMAL(7,2) = NULL
AS
		/*	
			Documentação
			Arquivo fonte........: Produtos.sql
			Objetivo.............: Inserir pedido de um produto para um fornecedor
			Autor................: Gustavo Targino
			Data.................: 08/05/2024
			Ex...................: BEGIN TRAN
									
										DECLARE @DataInicio DATE = GETDATE(),
												@Ret INT

										SELECT * FROM Produto
										SELECT * FROM Fornecedor
										SELECT * FROM ProdutoFornecedor

										EXEC @Ret = [dbo].[SP_GerarProdutoFornecedor]1, 1, 20, NULL

										SELECT * FROM Produto 
										SELECT * FROM Fornecedor
										SELECT * FROM ProdutoFornecedor
										SELECT @Ret Retorno

								   ROLLBACK
			Retornos.............: 0 - Pedido gerado ao fornecedor
								   1 - Não existe este fornecedor
								   2 - Não existe este produto
								   3 - A quantidade do pedido não pode ser negativa
								   4 - Preço do produto não pode ser negativo
								   5 - Erro ao inserir pedido ao fornecedor

		*/

	BEGIN

		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM [dbo].[Fornecedor]
								WHERE Id = @IdFornecedor
					  )
			RETURN 1

		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM [dbo].[Produto]
								WHERE Id = @IdProduto
					  )
			RETURN 2

		IF @Quantidade < 0
			RETURN 3

		-- NULL comparado com qualquer valor que seja não nulo sempre dará FALSE
		IF @PrecoCompra < 0 
			RETURN 4

		IF @PrecoCompra IS NULL
			-- 70% do valor do preço do produto * quantidade
			SELECT @PrecoCompra = (p.Preco * @Quantidade) * 0.7
				FROM [dbo].[Produto] p WITH(NOLOCK) 
					WHERE p.Id = @IdProduto
			
		BEGIN TRANSACTION

			BEGIN TRY
				INSERT INTO [dbo].[ProdutoFornecedor] (IdFornecedor, IdProduto, Quantidade, PrecoCompra, DataCompra)
					VALUES (@IdFornecedor, @IdProduto, @Quantidade, @PrecoCompra, GETDATE())
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 5
			END CATCH
			
			BEGIN TRY
				UPDATE [dbo].[Produto]
					SET Estoque = Estoque + @Quantidade
						WHERE Id = @IdProduto
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION
				RETURN 6
			END CATCH

		COMMIT TRANSACTION

		RETURN 0

	END