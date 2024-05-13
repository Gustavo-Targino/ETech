CREATE OR ALTER TRIGGER [dbo].[TRG_GerarPedidoFornecedorPorEstoqueBaixo]
	ON [dbo].[Produto]
	AFTER UPDATE
AS
		/*	
			Documentação
			Arquivo Fonte.........: TRG_GerarPedidoFornecedorPorEstoqueBaixo.sql
			Objetivo..............: Gerar um pedido para o fornecedor do produto que está com estoque menor ou igual a 10.
			Autor.................: Gustavo Targino
			Data..................: 08/05/2024
			Ex....................: BEGIN TRAN
										
										DECLARE @DataInicio DATETIME = GETDATE()


										SELECT * FROM [dbo].[ProdutoFornecedor] WHERE IdProduto = 1
										SELECT * FROM [dbo].[Produto] WHERE Id = 1

										UPDATE [dbo].[Produto]
											SET Estoque = 8
												WHERE Id = 1

										SELECT * FROM [dbo].[ProdutoFornecedor] WHERE IdProduto = 1
										SELECT * FROM [dbo].[Produto] WHERE Id = 1

									ROLLBACK
		*/

	BEGIN

		DECLARE @EstoqueProduto INT,
				@IdProduto INT,
				@IdFornecedor INT,
				@Ret INT

		SELECT @EstoqueProduto = Estoque,
			   @IdProduto = Id	
			FROM INSERTED

		IF(@EstoqueProduto <= 10)
			BEGIN
				
				SELECT @IdFornecedor = pf.IdFornecedor
					FROM [dbo].[ProdutoFornecedor] pf
						WHERE pf.IdProduto = @IdProduto
				
				EXEC @Ret = [dbo].[SP_GerarProdutoFornecedor] @IdFornecedor, @IdProduto, 10, NULL

				IF @Ret <> 0
					RAISERROR('Erro ao gerar pedido do produto ao fornecedor.', 16, 1)

			END
	END