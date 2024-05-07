CREATE DATABASE ETech;
GO

USE ETech;


CREATE TABLE Cargo (
	Id TINYINT IDENTITY,
	Nome VARCHAR(50) NOT NULL,
	Salario DECIMAL(7,2) NOT NULL,
	CONSTRAINT PK_Cargo PRIMARY KEY(Id)
);

CREATE TABLE Funcionario (
    Id INT IDENTITY,
	IdCargo TINYINT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
	Email VARCHAR(100) UNIQUE NOT NULL,
	Senha AS HASHBYTES('SHA2_256', Email),
	CPF CHAR(11) UNIQUE NOT NULL,
	DataContratacao DATE NOT NULL,
	DataRescisao DATE,
	CONSTRAINT PK_Funcionario PRIMARY KEY(Id),
	CONSTRAINT FK_CargoFuncionario FOREIGN KEY (IdCargo) REFERENCES Cargo(Id)
);

CREATE TABLE Cliente (
    Id INT IDENTITY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
	Senha AS HASHBYTES('SHA2_256', Email),
	CONSTRAINT PK_Cliente PRIMARY KEY(Id)
);

CREATE TABLE Produto (
    Id INT IDENTITY,
    Nome VARCHAR(100) NOT NULL,
    Preco DECIMAL(8,2) NOT NULL,
    Descricao VARCHAR(255) NOT NULL,
    Estoque INT NOT NULL,
	UsuarioCadastro INT NOT NULL,
	DataCadastro DATE NOT NULL,
	CONSTRAINT PK_Produto PRIMARY KEY(Id)
);

CREATE TABLE StatusRastreio (
    Id TINYINT IDENTITY,
    Nome VARCHAR(100) NOT NULL,
	CONSTRAINT PK_StatusRastreio PRIMARY KEY(Id)
);

CREATE TABLE Pedido (
    Id INT IDENTITY,
    IdCliente INT NOT NULL,
    IdFuncionario INT NOT NULL,
    DataPedido DATETIME NOT NULL,
	ValorTotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY(Id),
    CONSTRAINT FK_IdClientePedido FOREIGN KEY (IdCliente) REFERENCES Cliente(Id)
);

CREATE TABLE Rastreio (
	Id INT IDENTITY,
	IdPedido INT NOT NULL,
	IdStatusRastreio TINYINT,
	Data DATETIME NOT NULL,
	CONSTRAINT PK_Rastreio PRIMARY KEY(Id),
	CONSTRAINT FK_PedidoRastreio FOREIGN KEY(IdPedido) REFERENCES Pedido(Id),
	CONSTRAINT FK_IdStatusRastreioPedido FOREIGN KEY(IdStatusRastreio) REFERENCES StatusRastreio(Id)
);


CREATE TABLE PedidoProduto (
    IdPedido INT NOT NULL,
    IdProduto INT NOT NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT FK_IdPedidoProduto FOREIGN KEY (IdPedido) REFERENCES Pedido(Id),
    CONSTRAINT FK_IdProdutoPedido FOREIGN KEY (IdProduto) REFERENCES Produto(Id)
);

CREATE TABLE TelefoneCliente (
    Id INT IDENTITY,
	IdCliente INT NOT NULL,
    Telefone VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Telefone PRIMARY KEY(Id),
    CONSTRAINT FK_ClienteTelefone FOREIGN KEY (IdCliente) REFERENCES Cliente(Id)
);

CREATE TABLE UF(
	Id TINYINT IDENTITY,
	Sigla CHAR(2) NOT NULL,
	CONSTRAINT PK_UF PRIMARY KEY(Id)
);

CREATE TABLE EnderecoCliente (
    Id INT IDENTITY,
    IdCliente INT NOT NULL,
    Logradouro VARCHAR(100),
    Cidade VARCHAR(100),
    IdUF TINYINT NOT NULL,
    CEP VARCHAR(20),
    CONSTRAINT PK_EnderecoCliente PRIMARY KEY (Id),
    CONSTRAINT FK_ClienteEndereco FOREIGN KEY (IdCliente) REFERENCES Cliente(Id),
	CONSTRAINT FK_UFEnderecoCliente FOREIGN KEY(IdUF) REFERENCES UF(Id)
);

CREATE TABLE Fornecedor (
    Id SMALLINT IDENTITY,
	RazaoSocial VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    CONSTRAINT PK_Fornecedor PRIMARY KEY(Id)
);

CREATE TABLE TelefoneFornecedor (
    Id INT IDENTITY,
    IdFornecedor SMALLINT NOT NULL,
    Telefone VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Telefone_Fornecedor PRIMARY KEY(Id),
    CONSTRAINT FK_FornecedorTelefone FOREIGN KEY (IdFornecedor) REFERENCES Fornecedor(Id)
);

CREATE TABLE ProdutoFornecedor (
    IdFornecedor SMALLINT  NOT NULL,
    IdProduto INT NOT NULL,
    Quantidade INT NOT NULL,
    PrecoCompra DECIMAL(7,2) NOT NULL
    CONSTRAINT FK_IdFornecedorProduto FOREIGN KEY (IdFornecedor) REFERENCES Fornecedor(Id),
    CONSTRAINT FK_IdProdutoFornecedor FOREIGN KEY (IdProduto) REFERENCES Produto(Id)
);

CREATE TABLE SAC(
	
	Id INT IDENTITY,
	IdCliente INT NOT NULL,
	IdPedido INT NOT NULL,
	Solicitacao VARCHAR(250) NOT NULL,
	RespostaSac VARCHAR(250),
	Data DATE NOT NULL,
	CONSTRAINT PK_IdSAC PRIMARY KEY(Id),
	CONSTRAINT FK_IdClienteSAC FOREIGN KEY (IdCliente) REFERENCES Cliente(Id),
	CONSTRAINT FK_IdPedidoSAC FOREIGN KEY (IdPedido) REFERENCES Pedido(Id)

);

INSERT INTO Cargo (Nome, Salario) VALUES ('Desenvolvedor', 5000.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Gerente', 7000.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Analista', 4000.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Técnico de Suporte', 3000.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Designer Gráfico', 6000.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Marketing', 5500.00);
INSERT INTO Cargo (Nome, Salario) VALUES ('Contador', 7500.00);


INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (1, 'João Silva', 'joao.silva@email.com', '12345678901', '2023-01-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (2, 'Maria Santos', 'maria.santos@email.com', '23456789012', '2023-02-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (3, 'Carlos Pereira', 'carlos.pereira@email.com', '34567890123', '2023-03-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (4, 'Ana Costa', 'ana.costa@email.com', '45678901234', '2023-04-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (5, 'Pedro Ferreira', 'pedro.ferreira@email.com', '56789012345', '2023-05-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (6, 'Maria Oliveira', 'maria.oliveira@email.com', '67890123456', '2023-06-01');
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) VALUES (7, 'Carlos Martins', 'carlos.martins@email.com', '78901234567', '2023-07-01');


INSERT INTO Cliente (Nome, Email) VALUES ('João Silva', 'joao.silva@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Maria Santos', 'maria.santos@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Carlos Pereira', 'carlos.pereira@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Ana Costa', 'ana.costa@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Pedro Ferreira', 'pedro.ferreira@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Maria Oliveira', 'maria.oliveira@email.com');
INSERT INTO Cliente (Nome, Email) VALUES ('Carlos Martins', 'carlos.martins@email.com');

-- Contato para João Silva
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (1, '+55 11 98765-4321');

-- Contato para Maria Santos
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (2, '+55 21 98765-4321');

-- Contato para Carlos Pereira
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (3, '+55 31 98765-4321');

-- Contato para Ana Costa
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (4, '+55 41 98765-4321');

-- Contato para Pedro Ferreira
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (5, '+55 51 98765-4321');

-- Contato para Maria Oliveira
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (6, '+55 61 98765-4321');

-- Contato para Carlos Martins
INSERT INTO TelefoneCliente (IdCliente, Telefone) VALUES (7, '+55 71 98765-4321');


INSERT INTO UF (Sigla) VALUES ('AC');
INSERT INTO UF (Sigla) VALUES ('AL');
INSERT INTO UF (Sigla) VALUES ('AP');
INSERT INTO UF (Sigla) VALUES ('AM');
INSERT INTO UF (Sigla) VALUES ('BA');
INSERT INTO UF (Sigla) VALUES ('CE');
INSERT INTO UF (Sigla) VALUES ('DF');
INSERT INTO UF (Sigla) VALUES ('ES');
INSERT INTO UF (Sigla) VALUES ('GO');
INSERT INTO UF (Sigla) VALUES ('MA');
INSERT INTO UF (Sigla) VALUES ('MT');
INSERT INTO UF (Sigla) VALUES ('MS');
INSERT INTO UF (Sigla) VALUES ('MG');
INSERT INTO UF (Sigla) VALUES ('PA');
INSERT INTO UF (Sigla) VALUES ('PB');
INSERT INTO UF (Sigla) VALUES ('PR');
INSERT INTO UF (Sigla) VALUES ('PE');
INSERT INTO UF (Sigla) VALUES ('PI');
INSERT INTO UF (Sigla) VALUES ('RJ');
INSERT INTO UF (Sigla) VALUES ('RN');
INSERT INTO UF (Sigla) VALUES ('RS');
INSERT INTO UF (Sigla) VALUES ('RO');
INSERT INTO UF (Sigla) VALUES ('RR');
INSERT INTO UF (Sigla) VALUES ('SC');
INSERT INTO UF (Sigla) VALUES ('SP');
INSERT INTO UF (Sigla) VALUES ('SE');
INSERT INTO UF (Sigla) VALUES ('TO');


INSERT INTO StatusRastreio VALUES ('Aguardando envio');
INSERT INTO StatusRastreio VALUES ('Em trânsito');
INSERT INTO StatusRastreio VALUES ('Entregue');
INSERT INTO StatusRastreio VALUES ('Cancelado');
INSERT INTO StatusRastreio VALUES ('Retornado');
INSERT INTO StatusRastreio VALUES ('Aguardando pagamento');
INSERT INTO StatusRastreio VALUES ('Aguardando produtos');

INSERT INTO Produto VALUES ('Samsung Galaxy S21', 3999.00, 'Smartphone Android com 8GB de RAM e 128GB de armazenamento', 100, 4, GETDATE());
INSERT INTO Produto VALUES ('Apple iPhone 13 Pro', 6999.00, 'Smartphone iOS com 128GB de armazenamento e câmera de 12MP', 200, 4, GETDATE());
INSERT INTO Produto VALUES ('LG G8X ThinQ', 2999.00, 'Smartphone Android com 6GB de RAM e 128GB de armazenamento', 300, 4, GETDATE());
INSERT INTO Produto VALUES ('Sony WH-1000XM4', 349.00, 'Fones de ouvido sem fio com cancelamento de ruído', 400, 4, GETDATE());
INSERT INTO Produto VALUES ('Logitech MX Master 3', 299.00, 'Mouse sem fio com roda de alta precisão', 500, 4, GETDATE());
INSERT INTO Produto VALUES ('Dell XPS 15', 2999.00, 'Laptop com processador Intel Core i7 e 16GB de RAM', 600, 4, GETDATE());
INSERT INTO Produto VALUES ('Apple MacBook Pro 16"', 2499.00, 'Laptop com processador Apple M1 Pro e 16GB de RAM', 700, 4, GETDATE());


INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Amazon', 'contato@amazon.com', 11444777000191);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Apple Store', 'contato@apple.com', 12345678901234);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Samsung Store', 'contato@samsung.com', 23456789012345);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Microsoft Store', 'contato@microsoft.com', 34567890123456);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Logitech', 'contato@logitech.com', 45678901234567);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Dell', 'contato@dell.com', 56789012345678);
INSERT INTO Fornecedor (RazaoSocial, Email, CNPJ) VALUES ('Apple Store', 'contato@apple.com', 67890123456789);

-- Contatos para Amazon
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (1, '+55 11 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (1, '+55 11 8765-4321');

-- Contatos para Apple Store
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (2, '+55 21 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (2, '+55 21 8765-4321');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (7, '+55 71 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (7, '+55 71 8765-4321');

-- Contatos para Samsung Store
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (3, '+55 31 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (3, '+55 31 8765-4321');

-- Contatos para Microsoft Store
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (4, '+55 41 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (4, '+55 41 8765-4321');

-- Contatos para Logitech
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (5, '+55 51 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (5, '+55 51 8765-4321');

-- Contatos para Dell
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (6, '+55 61 1234-5678');
INSERT INTO TelefoneFornecedor (IdFornecedor, Telefone) VALUES (6, '+55 61 8765-4321');

-- Endereços para João Silva
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (1, 'Rua das Flores, 123', 'São Paulo', 1, '01000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (1, 'Avenida Brasil, 456', 'Rio de Janeiro', 2, '20000-000');

-- Endereços para Maria Santos
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (2, 'Rua dos Mineiros, 789', 'Belo Horizonte', 3, '30000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (2, 'Avenida Paulista, 101', 'São Paulo', 1, '01000-000');

-- Endereços para Carlos Pereira
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (3, 'Rua das Palmeiras, 111', 'Rio de Janeiro', 2, '20000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (3, 'Rua dos Tamoios, 121', 'Belo Horizonte', 3, '30000-000');

-- Endereços para Ana Costa
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (4, 'Avenida Rio Branco, 131', 'São Paulo', 1, '01000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (4, 'Rua das Flores, 123', 'São Paulo', 1, '01000-000');

-- Endereços para Pedro Ferreira
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (5, 'Rua dos Mineiros, 789', 'Belo Horizonte', 3, '30000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (5, 'Avenida Brasil, 456', 'Rio de Janeiro', 2, '20000-000');

-- Endereços para Maria Oliveira
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (6, 'Rua das Palmeiras, 111', 'Rio de Janeiro', 2, '20000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (6, 'Rua dos Tamoios, 121', 'Belo Horizonte', 3, '30000-000');

-- Endereços para Carlos Martins
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (7, 'Avenida Rio Branco, 131', 'São Paulo', 1, '01000-000');
INSERT INTO EnderecoCliente (IdCliente, Logradouro, Cidade, IdUF, CEP) VALUES (7, 'Rua das Flores, 123', 'São Paulo', 1, '01000-000');]

-- Inserir mais produtos
INSERT INTO Produto (Nome, Preco, Descricao, Estoque, UsuarioCadastro, DataCadastro) 
VALUES 
('Sony PlayStation 5', 4999.00, 'Console de videogame de última geração', 50, 4, GETDATE()),
('Nintendo Switch', 2999.00, 'Console de videogame híbrido', 100, 4, GETDATE()),
('Microsoft Xbox Series X', 4499.00, 'Console de videogame poderoso', 75, 4, GETDATE());

-- Inserir mais funcionários
INSERT INTO Funcionario (IdCargo, Nome, Email, CPF, DataContratacao) 
VALUES 
(1, 'Lucas Almeida', 'lucas.almeida@email.com', '89012345678', '2023-08-01'),
(2, 'Fernanda Lima', 'fernanda.lima@email.com', '90123456789', '2023-09-01'),
(3, 'Gustavo Santos', 'gustavo.santos@email.com', '01234567890', '2023-10-01');

-- Inserir alguns pedidos com diferentes status de rastreamento
DECLARE @PedidoID INT;

-- Pedido 1 - Aguardando envio
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(1, GETDATE(), 6999.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 2, 1); -- Nintendo Switch

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 1, GETDATE()); -- Aguardando envio

-- Pedido 2 - Em trânsito
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(2, 2, GETDATE(), 3499.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 3, 1); -- Microsoft Xbox Series X

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 2, DATEADD(DAY, -3, GETDATE())), -- Em trânsito há 3 dias
(@PedidoID, 2, DATEADD(DAY, -2, GETDATE())), -- Em trânsito há 2 dias
(@PedidoID, 2, DATEADD(DAY, -1, GETDATE())); -- Em trânsito há 1 dia

-- Pedido 3 - Entregue
INSERT INTO Pedido (IdCliente,DataPedido, ValorTotal) 
VALUES 
(3, GETDATE(), 2999.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 1, 1); -- Sony PlayStation 5

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 3, DATEADD(DAY, -1, GETDATE())); -- Entregue há 1 dia

-- Pedido 4 - Cancelado
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(4, GETDATE(), 299.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 4, 1); -- Sony WH-1000XM4

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 4, GETDATE()); -- Pedido cancelado

-- Pedido 5 - Retornado
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(5, GETDATE(), 299.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 5, 1); -- Logitech MX Master 3

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 5, DATEADD(DAY, -2, GETDATE())), -- Retornado há 2 dias
(@PedidoID, 5, DATEADD(DAY, -1, GETDATE())); -- Retornado há 1 dia

-- Pedido 6 - Aguardando pagamento
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(6, GETDATE(), 2999.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 6, 1); -- Dell XPS 15

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 6, GETDATE()); -- Aguardando pagamento

-- Pedido 7 - Aguardando produtos
INSERT INTO Pedido (IdCliente, DataPedido, ValorTotal) 
VALUES 
(7, GETDATE(), 2499.00);

SET @PedidoID = SCOPE_IDENTITY();

INSERT INTO PedidoProduto (IdPedido, IdProduto, Quantidade) 
VALUES 
(@PedidoID, 7, 1); -- Apple MacBook Pro 16"

INSERT INTO Rastreio (IdPedido, IdStatusRastreio, Data) 
VALUES 
(@PedidoID, 7, GETDATE()); -- Aguardando produtos
