<?php
class geraVisGlobal {
	private $configDB;
	
	function __construct($configDB) {
		$this->configDB = $configDB;
	}

    /*NESSE ARQUIVO DEVE-SE ALTERAR A FUNÇÃO criaViewCache. NÃO É MAIS NECESSÁRIO DIVIDIR A REDE EM DUAS PARTES. SERÁ UMA REDE SÓ. ENTÃO, CRIA UMA VISÃO COM TODAS AS PUBLICAÇÕES EXISTENTES NO BANCO. NÃO É NECESSÁRIO ESSA CONDIÇÃO "id NOT IN (SELECT id FROM publicacao_ano_superior_2008)" E NEM ESSA "YEAR(data_publicacao) <= 2010 AND YEAR(data_publicacao) >= 2000". ATENÇÃO TODOS OS OUTROS ARQUIVOS QUE UTILIZAREM A VIEW publicacao_ano_superior_2008 DEVEM SER MODIFICADOS PARA CONSIDERAR APENAS A VISÃO "publicacao_ano_inferior_2008" (SUGIRO MUDAR O NOME DESSA VISÃO PARA coauthorship_network - ISSO DEVERÁ SER ALTERADO EM OUTROS ARQUIVOS QUE USAM ESSA VIEW).*/
    
	/* Cria view de gabarito */
	/*Cria uma vis„o que ser· utilizada como gabarito, pois considera autores que publicaram em um ano posterior*/
	
	
	/* Cria view de cache */
	/* Essas duas funÁıes s„o IMPORTANTES, pois inserem os pesquisadores na tabela autor_publicacao_instituicao. 
	Os pesquisadores dessa tabela ser„o utilizados nos experimentos.*/
	public function criaViewCache() {
	 

		if(!mysql_query('CREATE VIEW coauthorship_network AS SELECT id FROM '.$this->configDB->tabelaPublicacao.' WHERE (publicacao_replica_id is NULL OR publicacao_replica_id = id OR id IN (select p.id from publicacao p, autoria_autor_publicacao a 
where p.id <> p.publicacao_replica_id and p.id = a.publicacao_id and not exists
(
select 1 
from publicacao p1,  autoria_autor_publicacao a1
where p1.id = p.publicacao_replica_id
and p1.id = a1.publicacao_id
and a1.autor_id = a.autor_id
) ORDER BY YEAR(data_publicacao) DESC) )'))
		{
			throw new Exception('Erro ao criar a View para o publicacao < 2008: <em>'.mysql_error().'</em>.');
		}


		if(!mysql_query('CREATE VIEW autor_publicacao_instituicao_aux AS SELECT DISTINCT a.id as autor_id, api.inct_id, instituicao_id, p.id as publicacao_id FROM '.$this->configDB->tabelaAutor.' AS a INNER JOIN '.$this->configDB->tabelaAssociacaoPesquisadorInstituicao.' AS api ON a.pesquisador_id = api.pesquisador_id INNER JOIN '.$this->configDB->tabelaAutorPublicacao.' AS ap ON a.id = ap.autor_id INNER JOIN coauthorship_network p ON p.id = ap.publicacao_id WHERE a.selecao <> 0 AND instituicao_id IS NOT NULL'))
			throw new Exception('Erro ao criar a View para o autor_publicacao_instituicao_aux: <em>'.mysql_error().'</em>.');

		$this->insert_autor_publicacao_instituicao();

		if(!mysql_query('CREATE VIEW '.$this->configDB->viewGrafoGeral.' AS SELECT a.autor_id AS autor1, a.instituicao_id AS inst_autor1, b.autor_id AS autor2, b.instituicao_id AS inst_autor2, YEAR(p.data_publicacao) as ano, COUNT(*) as num_publicacoes FROM autor_publicacao_instituicao a, autor_publicacao_instituicao b, '.$this->configDB->tabelaPublicacao.' p WHERE a.publicacao_id = b.publicacao_id AND a.autor_id != b.autor_id AND p.id = a.publicacao_id GROUP BY a.autor_id, a.instituicao_id, b.autor_id, b.instituicao_id, p.data_publicacao'))
			throw new Exception('Erro ao criar a View para o grafo geral: <em>'.mysql_error().'</em>.');
	}

	public function insert_autor_publicacao_instituicao()
	{
		$sucesso=TRUE;		
		$query = mysql_query('SELECT DISTINCT autor_id, instituicao_id, publicacao_id FROM autor_publicacao_instituicao_aux');

        	while($fetch = mysql_fetch_array($query)) 
		{
			$sucesso &= mysql_query('INSERT INTO autor_publicacao_instituicao (autor_id, instituicao_id, publicacao_id) VALUES ('.$fetch["autor_id"].', '.$fetch["instituicao_id"].', '.$fetch["publicacao_id"].')');

		}
	}

	
}

?>
