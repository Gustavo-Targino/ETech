CREATE OR ALTER FUNCTION [dbo].[FNC_ListaEnderecoCliente](@IdCliente INT = NULL)
	RETURNS @Tabela TABLE(IdCliente INT, Nome VARCHAR(100), Email VARCHAR(100), IdEndereco INT)
AS
		/*
			Documentação

			Arquivo fonte......: FNC_ListaEnderecoCliente.sql
			Objetivo...........: Listar todos os endereços de um cliente
			Autor..............: Gustavo Targino
			Data...............: 06/05/2024
			Ex.................: BEGIN TRAN
								
								SELECT * FROM [dbo].[FNC_ListaEnderecoCliente](1)

							 ROLLBACK	

		*/

	BEGIN
		
		INSERT INTO @Tabela
			SELECT cl.Id,
				   cl.Nome,
				   cl.Email,
				   ec.Id
				FROM [dbo].[Cliente] cl WITH(NOLOCK)
					INNER JOIN [dbo].[EnderecoCliente] ec
						ON cl.Id = ec.IdCliente
				WHERE cl.Id = ISNULL(@IdCliente, cl.Id)

		RETURN
	END