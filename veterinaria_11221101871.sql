-- Adriano Teruo Shibuya  RGM: 11221101871
create schema veterinaria;
 
use veterinaria;
 
 -- tabela paciente
create table pacientes(
id_paciente integer primary key  auto_increment,
nome varchar (100),
especie varchar (100),
idade integer
);
  
-- tabela veterinarios
create table veterinarios(
id_veterinario integer primary key auto_increment,
nome varchar (100),
especialidade varchar (50)
);
 
 
 -- tabela consultas
CREATE TABLE Consultas (
    id_consulta integer primary key auto_increment,
    id_paciente integer,
    id_veterinario integer,
    data_consulta date,
    custo decimal(10, 2),
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario)
    );
 
 -- tabela de log das consultas
 CREATE TABLE Log_Consultas (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    custo_antigo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2)
);

 
 
DELIMITER $$
-- criar a procedure agendar_consulta
CREATE PROCEDURE agendar_consulta (
-- parametros
    IN p_id_paciente INTEGER,
    IN p_id_veterinario INTEGER,
    IN p_data_consulta DATE,
    IN p_custo DECIMAL(10, 2)
)
BEGIN
-- inserir dados nas tabelas 
    INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (p_id_paciente, p_id_veterinario, p_data_consulta, p_custo);
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE atualizar_paciente (
-- parametros 
    IN p_id_paciente INTEGER,
    IN p_novo_nome VARCHAR(100),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INTEGER
)
BEGIN
-- ações que serao executadas
    UPDATE Pacientes
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE remover_consulta (
-- parametro
    IN p_id_consulta INTEGER
)
BEGIN
-- deletar consulta
    DELETE FROM Consultas
    WHERE id_consulta = p_id_consulta;
END $$

DELIMITER ;

-- inserts para testar as tabelas e procedures
INSERT INTO Pacientes (nome, especie, idade) VALUES ('jujuba', 'Cachorro', 8);
INSERT INTO Veterinarios (nome, especialidade) VALUES ('DrAndre', 'cirurgia');

-- chamando as procedures para testar
CALL agendar_consulta(1, 1, '2024-09-20', 55.00);
CALL atualizar_paciente(1, 'bilu', 'gato', 5);
CALL remover_consulta(1);
CALL agendar_consulta(2, 1, '2024-09-26', 125.00);

DELIMITER $$

-- function para mostrar o valor total gasto pelo paciente em consultas.
CREATE FUNCTION total_gasto_paciente (
    p_id_paciente INT
)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    
SELECT 
    SUM(custo)
INTO total FROM
    Consultas
WHERE
    id_paciente = p_id_paciente;
    
    RETURN total;
END$$

DELIMITER ;

-- select para testar a function
SELECT total_gasto_paciente(1) AS total_gasto;


DELIMITER $$
-- trigger para verificar idade do paciente
CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON Pacientes
FOR EACH ROW
BEGIN
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        -- menssagem que vai ser exibida se a idade não for positiva
        SET MESSAGE_TEXT = 'A idade do paciente deve ser um número positivo.';
    END IF;
END$$

DELIMITER ;

-- insert para testar a trigger da idade
INSERT INTO Pacientes (nome, especie, idade) VALUES ('birulei', 'Cachorro', -2);


DELIMITER $$
-- trigger para salvar alterações do custo das consultas
CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON Consultas
FOR EACH ROW
BEGIN
    IF NEW.custo <> OLD.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END$$

DELIMITER ;

-- update para testar a trigger
UPDATE Consultas
SET custo = 200.00
WHERE id_consulta = 4;

-- select para mostrar o log da consulta alterada
SELECT * FROM Log_Consultas;
