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

		*/
	BEGIN

		UPDATE Produto
				SET Estoque = Estoque + @Quantidade
					WHERE Id = @IdProduto

	END