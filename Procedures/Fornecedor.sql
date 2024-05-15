CREATE OR ALTER PROCEDURE [dbo].[SP_RankProdutosFornecedor]
	@IdFornecedor INT = NULL
AS
		/*
			Documentação

			Arquivo fonte.......: Fornecedor.sql
			Objetivo............: Listar os produtos com maior demanda de cada fornecedor ou de todos os vendedores
			Autor...............: Gustavo Targino
			Data................: 15/05/2024
			Ex..................: BEGIN TRAN
										
										DECLARE @DataInicio DATETIME = GETDATE(),
												@Ret INT
									
									EXEC @Ret = [dbo].[SP_RankProdutosFornecedor] 1

									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) Tempo,
										   @Ret Retorno

								  ROLLBACK
			Retornos............: 0 - Dados retornados
							      1 - Esse fornecedor não existe
		*/
	BEGIN
	
		IF NOT EXISTS (
						SELECT TOP 1 1
							FROM [dbo].[Fornecedor] f WITH(NOLOCK)
								WHERE f.Id = @IdFornecedor
					  )
			RETURN 1


		SELECT f.RazaoSocial,
			   p.Nome,
			   p.Descricao,
			   RANK() OVER(PARTITION BY f.RazaoSocial ORDER BY COUNT(f.Id) DESC) Rank
			FROM [dbo].[ProdutoFornecedor] pf WITH(NOLOCK)
				INNER JOIN [dbo].[Produto] p WITH(NOLOCK)
					ON p.Id = pf.IdProduto
				INNER JOIN [dbo].[Fornecedor] f WITH(NOLOCK)
					ON f.Id = pf.IdFornecedor
			WHERE f.Id = ISNULL(@IdFornecedor, f.id)
			GROUP BY  f.RazaoSocial,
					  p.Nome,
					  p.Descricao,
					  p.Id

	END
