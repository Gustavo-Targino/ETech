CREATE OR ALTER FUNCTION [dbo].[FNC_VerificaEstoqueProduto](@IdProduto INT)
	RETURNS INT
AS

	/*
		Documentação
		Arquivo Fonte.....: FNC_VerificaEstoqueProduto.sql
		Objetivo..........: Function que retorna o estoque do produto com base no Id
		Autor.............: Gustavo Targino
		Data..............: 08/04/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								SELECT [dbo].[FNC_VerificaEstoqueProduto](2) Estoque;

								SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS Tempo;

							ROLLBACK TRAN
	*/

	BEGIN
		
		RETURN (
		SELECT Estoque 
			FROM [dbo].[Produto]
			WHERE Id = @IdProduto
		)
		
	END