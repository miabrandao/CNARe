<?php
class recomendacao {
	private $configDB;
	
	function __construct($configDB) {
		$this->configDB = $configDB;
	}
    
    /* NESSE ARQUIVO, DEVE-SE ALTERAR A FUNÇÃO calculaImportanciaAutorTema E AS DEMAIS QUE USAREM TEMA_ID. VERIFICAR TAMBÉM AS CONDIÇÕES NA CONSULTA SQL QUE FILTRAM PELO ANO.*/

		/* Retorna a importancia da localidade */
	private function recupera_importancia_loc($autor_a, $instituicao_b) {

		$autor_a = round($autor_a);
		$instituicao_b = round($instituicao_b);
		
		$query = mysql_query('SELECT importancia FROM '.$this->configDB->tabelaImportanciaAutorLocalizacao.' WHERE id_autor='.$autor_a.' AND id_instituicao='.$instituicao_b);
		
		if(mysql_num_rows($query) == 0)
			return 0;
		else {
			$fetch = mysql_fetch_array($query);
			return $fetch["importancia"];
		}
	}


        //Calcula a cooperação dos coautores, agrupando por instituição
	public function calculaCooperacaoAgrupandoInstituicao() 
	{
		$sucesso = true;

		$query = mysql_query('SELECT instituicao1, count(DISTINCT autor1) as tot_pesq FROM recomendacao_local where cooperacao > 0 group by instituicao1');

		while($fetch = mysql_fetch_array($query)) 
		{
			$query_coautoria = mysql_query('SELECT instituicao2, count(autor2) as tot_coop from recomendacao_local where cooperacao > 0 and instituicao1='.$fetch["instituicao1"].' group by instituicao2');

			while($fetch_coautoria = mysql_fetch_array($query_coautoria)) 
			{
				$cooperacaoInst = $fetch_coautoria["tot_coop"]/$fetch["tot_pesq"];
				
				$query_aux = mysql_query('SELECT temp_desloc from recomendacao_local where instituicao1='.$fetch["instituicao1"].' and instituicao2='.$fetch_coautoria["instituicao2"].' limit 1');

				$temp_desloc = mysql_result($query_aux, 0);


				$sucesso &= mysql_query('INSERT INTO cooperacao_agrupada_instituicao(instituicao1, instituicao2, cooperacao) VALUES ('.$fetch["instituicao1"].','.$fetch_coautoria["instituicao2"].','.$cooperacaoInst.')');
				

				if($sucesso!=true)
		    			throw new Exception('Erro ao calcular a cooperacao agrupada: <em>'.mysql_error().'</em>.');

			}

		}
		
	}


	/* Calcula a cooperacao absoluta de todos os coautores e salva no banco */
	public function calculaCooperacaoAbsoluta() 
	{
        	// variavel para controlar se a funcao executou com sucesso
        	$sucesso = true;

		// numero total de artigos de cada autor
		//$query = mysql_query('SELECT autor_id, count(*) as total_artigos FROM `'.$this->configDB->tabelaAutorPublicacao.'` GROUP BY autor_id');

		//Seleciona apenas autores dos INCTs 60 (INCT de Engenharia de Software), 64 (INCT de Sistemas Embarcados Críticos) e 77 (InWeb)
		$query = mysql_query('SELECT DISTINCT autor1 FROM recomendacao_local where cooperacao > 0 and cooperacao_absoluta is NULL');


        	while($fetch = mysql_fetch_array($query)) 
		{
            		// numero de artigos em comum de cada coautor do autor do loop externo
            		$query_coautoria = mysql_query('SELECT api.autor_id, count(*) as artigos_comum, MAX(YEAR(data_publicacao)) as year FROM autor_publicacao_instituicao api INNER JOIN publicacao p ON api.publicacao_id = p.id WHERE api.autor_id!='.$fetch["autor1"].' AND api.publicacao_id IN (SELECT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$fetch["autor1"].') GROUP BY api.autor_id');

            
            		while($fetch_coautoria = mysql_fetch_array($query_coautoria)) 
			{

		        	$sucesso &= mysql_query('UPDATE recomendacao_local SET cooperacao_absoluta='.$fetch_coautoria["artigos_comum"].' WHERE autor1='.$fetch["autor1"].' AND autor2='.$fetch_coautoria["autor_id"]);
            		}
        	}

		if($sucesso!=true)
		    throw new Exception('Erro ao calcular a metrica de cooperação absoluta: <em>'.mysql_error().'</em>.');
	}

	
	/* Calcula a cooperacao de todos os coautores e salva no banco */
	public function calculaCooperacao() 
	{
        	// variavel para controlar se a funcao executou com sucesso
        	$sucesso = true;

		// numero total de artigos de cada autor
		//$query = mysql_query('SELECT autor_id, count(*) as total_artigos FROM `'.$this->configDB->tabelaAutorPublicacao.'` GROUP BY autor_id');

		//Seleciona apenas autores dos INCTs 60 (INCT de Engenharia de Software), 64 (INCT de Sistemas Embarcados Críticos) e 77 (InWeb)
		$query = mysql_query('SELECT autor_id, count(*) AS total_artigos FROM autor_publicacao_instituicao GROUP BY autor_id');


        	while($fetch = mysql_fetch_array($query)) 
		{
            		// numero de artigos em comum de cada coautor do autor do loop externo
            		$query_coautoria = mysql_query('SELECT api.autor_id, count(*) as artigos_comum, MAX(YEAR(data_publicacao)) as year FROM autor_publicacao_instituicao api INNER JOIN publicacao p ON api.publicacao_id = p.id WHERE api.autor_id!='.$fetch["autor_id"].' AND api.publicacao_id IN (SELECT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$fetch["autor_id"].') GROUP BY api.autor_id');

            
            		while($fetch_coautoria = mysql_fetch_array($query_coautoria)) 
			{
				//Calcula o aspecto temporal
				//$aspc_temporal = $this->calcAspecTemporal($fetch["autor_id"], $fetch_coautoria["autor_id"],$fetch_coautoria["year"]);
				$aspc_temporal = 0;

		        	// calcula a cooperacao dos autores e insere na tabela de recomendacao
		        	$cooperacao = $fetch_coautoria["artigos_comum"] / $fetch["total_artigos"];

		        	$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacao.' (autor1, autor2, cooperacao, aspc_temporal) VALUES ('.$fetch["autor_id"].', '.$fetch_coautoria["autor_id"].', '.$cooperacao.','.$aspc_temporal.')');
            		}
        	}

		if($sucesso!=true)
		    throw new Exception('Erro ao calcular a metrica de cooperação: <em>'.mysql_error().'</em>.');
	}



	/* Calcula a influência da localidade e salva no banco */
	public function calculaCooperacaoLocalidade($autor_id1, $autor_id2) 
	{
        	// variavel para controlar se a funcao executou com sucesso
        	$sucesso = true;

		//Seleciona apenas autores dos INCTs 60 (INCT de Engenharia de Software), 64 (INCT de Sistemas Embarcados Críticos) e 77 (InWeb)
		$query = mysql_query('SELECT count(*) AS total_artigos FROM autor_publicacao_instituicao WHERE autor_id='.$autor_id1);

		$query_coautoria = mysql_query('SELECT count(*) AS tot_artigos_colabor FROM autor_publicacao_instituicao a WHERE a.autor_id='.$autor_id2.' AND a.publicacao_id IN (SELECT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$autor_id1.')');


		$quantidade_total = mysql_result($query, 0);

		$quantidade_colaboracao = mysql_result($query_coautoria, 0);
		

              	// calcula a colaboração
		$cooperacao = $quantidade_colaboracao / $quantidade_total;
	
        	$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET cooperacao = '.$cooperacao.' WHERE autor1 = '.$autor_id1.' AND autor2 = '.$autor_id2);
				

		if($sucesso!=true)
		    throw new Exception('Erro ao calcular a cooperacao: <em>'.mysql_error().'</em>.');
	}

	

	/* Retorna a cooperacao entre o pesquisador a e b */
	private function recupera_cooperacao($autor_a, $autor_b) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);
		
		$query = mysql_query('SELECT cooperacao FROM '.$this->configDB->tabelaRecomendacao.' WHERE autor1='.$autor_a.' AND autor2='.$autor_b);
		
		if(mysql_num_rows($query) == 0)
			return 0;
		else {
			$fetch = mysql_fetch_array($query);
			return $fetch["cooperacao"];
		}
	}

	/* Retorna a cooperacao entre o pesquisador a e b baseando na localizacao */
	private function recupera_cooperacao_local($autor_a, $autor_b) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);
		
		$query = mysql_query('SELECT cooperacao FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1='.$autor_a.' AND autor2='.$autor_b);
		
		if(mysql_num_rows($query) == 0)
			return 0;
		else {
			$fetch = mysql_fetch_array($query);
			return $fetch["cooperacao"];
		}
	}
	
	/* Retorna o total de publicacoes de um determinado autor */
	private function recuperaTotalPublicacoes($autor_id) {
		$autor_id = round($autor_id);
		$query = mysql_query('SELECT COUNT(*) as total FROM autor_publicacao_instituicao WHERE autor_id='.$autor_id);
		$fetch = mysql_fetch_array($query);
		return $fetch['total'];
	}
	
    
    /* ESSA FUNÇÃO DEVERÁ SER ALTERADA DE ACORDO A MODELAGEM DO BANCO, OU SEJA, tema_id NÃO ESTÁ MAIS NA TABELA PUBLICAÇÃO. TAMBÉM NÃO É MAIS NECESSÁRIO CONSIDERAR CONDIÇÕES COMO , POR EXEMPLO, YEAR(p.data_publicacao) < 2008 */
    
	/* Calcula a importancia de cada tema para cada autor */
	private function calculaImportanciaAutorTema() {
		// Calcula a quantidade de artigos de cada autor em cada tema
		$query = mysql_query('SELECT DISTINCT ap.autor_id, p.tema_id, COUNT(*) as quantidade FROM autor_publicacao_instituicao ap INNER JOIN '.$this->configDB->tabelaPublicacao.' p ON p.id = ap.publicacao_id WHERE p.tema_id IS NOT NULL GROUP BY ap.autor_id, p.tema_id');
		// Substituir query acima pela abaixo para rodar a rede do inweb. Isso eh necessario pq a rede do inweb tem temas como 'nao especificado' cadastrados e isso poderia atrapalhar as metricas de recomendacao
		//$query = mysql_query('SELECT ap.id_autor, t.id as id_tema, COUNT(*) as quantidade FROM '.$this->configDB->tabelaAutorPublicacao.' ap, '.$this->configDB->tabelaTema.' t, '.$this->configDB->tabelaPublicacao.' p WHERE t.id = p.id_tema AND p.id = ap.id_publicacao AND t.nome!="16" AND t.nome != "31" GROUP BY ap.id_autor, t.id');
		
		// a partir da quantidade de artigos por tema de cada autor calcula a importancia do tema para aquele autor
		while($fetch = mysql_fetch_array($query)) {
			$importancia = $fetch['quantidade'] / $this->recuperaTotalPublicacoes($fetch['autor_id']);
			mysql_query('INSERT INTO '.$this->configDB->tabelaImportanciaAutorTema.' (id_autor, id_tema, importancia) VALUES ('.$fetch["autor_id"].','.$fetch["tema_id"].','.$importancia.')');
		}
	}


	/* Calcula a importancia de cada localização para cada autor */
	public function calculaImportanciaAutorLocalizacao() {

		// variavel para controlar se a funcao executou com sucesso
        	$sucesso = true;

		//Seleciona apenas autores dos INCTs 60 (INCT de Engenharia de Software), 64 (INCT de Sistemas Embarcados Críticos) e 77 (InWeb)
		$query = mysql_query('SELECT DISTINCT autor_id, instituicao_id FROM autor_publicacao_instituicao');

        	while($fetch = mysql_fetch_array($query)) 
		{
            		// numero de artigos em comum de cada coautor do autor do loop externo
            		$query_coautoria = mysql_query('SELECT api.autor_id, instituicao_id, MAX(YEAR(data_publicacao)) as year FROM autor_publicacao_instituicao api INNER JOIN publicacao p ON api.publicacao_id = p.id WHERE api.autor_id!='.$fetch["autor_id"].' AND api.publicacao_id IN (SELECT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$fetch["autor_id"].') GROUP BY api.autor_id');
            
            		while($fetch_coautoria = mysql_fetch_array($query_coautoria)) 
			{

				//echo "Class: ".recupera_importancia_loc(3, 3)."\n\n";
		
				//Calcula o aspecto temporal
				//$aspc_temporal = $this->calcAspecTemporal($fetch["autor_id"], $fetch_coautoria["autor_id"], $fetch_coautoria["year"]);
				$aspc_temporal = 0;

				$importancia = $this->recupera_importancia_loc($fetch["autor_id"], $fetch_coautoria["instituicao_id"]);

				$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacaoLocal.' (autor1, instituicao1, autor2, instituicao2, importancia, aspc_temporal) VALUES ('.$fetch["autor_id"].', '.$fetch["instituicao_id"].', '.$fetch_coautoria["autor_id"].', '.$fetch_coautoria["instituicao_id"].','.$importancia.','.$aspc_temporal.')');

				$this->calculaCooperacaoLocalidade($fetch["autor_id"], $fetch_coautoria["autor_id"]);

			}



        }

		if($sucesso!=true)
		        throw new Exception('Erro ao inserir na tabela de recomenda localidade: <em>'.mysql_error().'</em>.');

	}
	
	/* Retorna a similaridade entre o pesquisador a e b */
	private function recupera_similaridade_local($autor_a, $autor_b) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);
		
		$query = mysql_query('SELECT similaridade FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1='.$autor_a.' AND autor2='.$autor_b);
		
		if(mysql_num_rows($query) == 0)
			return 0;
		else {
			$fetch = mysql_fetch_array($query);
			return $fetch["similaridade"];
		}
	}

	
	/* Retorna a similaridade entre o pesquisador a e b */
	private function recupera_similaridade($autor_a, $autor_b) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);
		
		$query = mysql_query('SELECT similaridade FROM '.$this->configDB->tabelaRecomendacao.' WHERE autor1='.$autor_a.' AND autor2='.$autor_b);
		
		if(mysql_num_rows($query) == 0)
			return 0;
		else {
			$fetch = mysql_fetch_array($query);
			return $fetch["similaridade"];
		}
	}



	//Função para calcular a importancia da localidade para cada autor
	public function define_importancia_localidade()
	{

		$sucesso = TRUE;

		//Seleciona apenas autores dos INCTs 60 (INCT de Engenharia de Software), 64 (INCT de Sistemas Embarcados Críticos) e 77 (InWeb)
		$query = mysql_query('SELECT DISTINCT autor_id FROM autor_publicacao_instituicao ORDER BY autor_id');

        	while($fetch = mysql_fetch_array($query)) 
		{

			$aux = mysql_query('SELECT count(DISTINCT publicacao_id) AS quantidade_total FROM autor_publicacao_instituicao WHERE autor_id='.$fetch["autor_id"]);
			$quantidade_total = mysql_result($aux, 0);

            		// numero de artigos em comum de cada coautor do autor do loop externo
            		$query_coautoria = mysql_query('SELECT DISTINCT instituicao_id FROM autor_publicacao_instituicao a WHERE a.autor_id!='.$fetch["autor_id"].' AND a.publicacao_id IN (SELECT DISTINCT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$fetch["autor_id"].') AND a.instituicao_id is not null ORDER BY autor_id');
            
			//Insere a importancia da instituicao para o autor
            		while($fetch_coautoria = mysql_fetch_array($query_coautoria)) 
			{

				$aux2 = mysql_query('SELECT count(DISTINCT publicacao_id) AS quantidade FROM autor_publicacao_instituicao a WHERE a.autor_id!='.$fetch["autor_id"].' AND a.publicacao_id IN (SELECT DISTINCT publicacao_id FROM autor_publicacao_instituicao a WHERE a.autor_id='.$fetch["autor_id"].') AND a.instituicao_id='.$fetch_coautoria["instituicao_id"].' order by publicacao_id');

				$quantidade = mysql_result($aux2, 0);


				$importancia = $quantidade / $quantidade_total;

				$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaImportanciaAutorLocalizacao.' (id_autor, id_instituicao, importancia) VALUES ('.$fetch["autor_id"].', '.$fetch_coautoria["instituicao_id"].', '.$importancia.')');

			}
		}

		if($sucesso!=true)
		    throw new Exception('Erro ao calcular a metrica de influencia de localidade: <em>'.mysql_error().'</em>.');
	

	}
	
	private function define_similaridade($autor_a,$autor_b, $similaridade) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);
		
		$sucesso = true;
		
		// armazena a similaridade na entrada autor1 -> autor2
		if($this->recupera_cooperacao($autor_a,$autor_b) == 0 && $similaridade != 0) {
			$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacao.' (autor1, autor2, cooperacao, aspc_temporal, similaridade) VALUES ('.$autor_a.', '.$autor_b.', 0, 0, '.$similaridade.')');
		} elseif($this->recupera_cooperacao($autor_a,$autor_b) != 0) {
			$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacao.' SET similaridade = '.$similaridade.' WHERE autor1='.$autor_a.' AND autor2 ='.$autor_b);
		}
		
		// armazena a similaridade na entrada autor2 -> autor1
		if($this->recupera_cooperacao($autor_b,$autor_a) == 0 && $similaridade != 0) {
			$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacao.' (autor1, autor2, cooperacao, aspc_temporal, similaridade) VALUES ('.$autor_b.', '.$autor_a.', 0, 0, '.$similaridade.')');
		} elseif($this->recupera_cooperacao($autor_a,$autor_b) != 0) {
			$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacao.' SET similaridade = '.$similaridade.' WHERE autor1='.$autor_b.' AND autor2 ='.$autor_a);
		}
		
		if($sucesso!=true)
            		throw new Exception('Erro ao calcular a metrica de corelação: <em>'.mysql_error().'</em>.');
            
	}

	private function define_similaridade_local($autor_a, $instituicao_a, $autor_b, $instituicao_b, $similaridade) {
		$autor_a = round($autor_a);
		$autor_b = round($autor_b);

		$instituicao_a = round($instituicao_a);
		$instituicao_b = round($instituicao_b);
		
		$sucesso = true;

		$importancia = $this->recupera_importancia_loc($autor_a, $instituicao_b);

		
		// armazena a similaridade na entrada autor1 -> autor2
		if($this->recupera_cooperacao_local($autor_a,$autor_b) == 0 && $similaridade != 0) {
			$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacaoLocal.' (autor1, instituicao1, autor2, instituicao2, cooperacao, aspc_temporal, similaridade, importancia) VALUES ('.$autor_a.', '.$instituicao_a.', '.$autor_b.', '.$instituicao_b.', 0, 0, '.$similaridade.','.$importancia.')');
		} elseif($this->recupera_cooperacao_local($autor_a,$autor_b) != 0) {
			$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET similaridade = '.$similaridade.' WHERE autor1='.$autor_a.' AND autor2 ='.$autor_b);
		}
		
		$importancia = $this->recupera_importancia_loc($autor_b, $instituicao_a);

		// armazena a similaridade na entrada autor2 -> autor1
		if($this->recupera_cooperacao_local($autor_b,$autor_a) == 0 && $similaridade != 0) {
			$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacaoLocal.' (autor1, instituicao1, autor2, instituicao2, cooperacao, aspc_temporal, similaridade, importancia) VALUES ('.$autor_b.', '.$instituicao_b.', '.$autor_a.', '.$instituicao_a.', 0, 0, '.$similaridade.','.$importancia.')');
		} elseif($this->recupera_cooperacao_local($autor_a,$autor_b) != 0) {
			$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET similaridade = '.$similaridade.' WHERE autor1='.$autor_b.' AND autor2 ='.$autor_a);
		}
		
		if($sucesso!=true)
            		throw new Exception('Erro ao calcular a metrica de corelação usando a localizacao: <em>'.mysql_error().'</em>.');
            
	}

	
	/* Calcula a similaridade entre os autores */
	private function calculaSimilaridade() {
		$query_autor1 = mysql_query('SELECT DISTINCT autor_id FROM autor_publicacao_instituicao ORDER BY autor_id');
		while($autor1 = mysql_fetch_array($query_autor1)) {
			$query_autor2 = mysql_query('SELECT DISTINCT autor_id FROM autor_publicacao_instituicao WHERE autor_id > '.$autor1["autor_id"].' ORDER BY autor_id');
			while($autor2 = mysql_fetch_array($query_autor2)) {
				$modulo_vetor1 = 0;
				$modulo_vetor2 = 0;
				$similaridade = 0;
				$modV2_calculado = false;
				
				$query_pubAutor1 = mysql_query('SELECT * FROM '.$this->configDB->tabelaImportanciaAutorTema.' WHERE id_autor='.$autor1["autor_id"]);
				while($pubAutor1 = mysql_fetch_array($query_pubAutor1)) {
					$modulo_vetor1 += pow($pubAutor1["importancia"],2);
					
					$query_pubAutor2 = mysql_query('SELECT * FROM '.$this->configDB->tabelaImportanciaAutorTema.' WHERE id_autor='.$autor2["autor_id"]);
					while($pubAutor2 = mysql_fetch_array($query_pubAutor2)) {
						if($modV2_calculado == false) {
							 $modulo_vetor2 += pow($pubAutor2["importancia"],2);
						}
						
						if($pubAutor1["id_tema"] == $pubAutor2["id_tema"]) {
							 $similaridade += $pubAutor1["importancia"] * $pubAutor2["importancia"];
							 
							 if($modV2_calculado == true)
								break;
						}	
					}
					$modV2_calculado = true;
				}
				
				$divisor = sqrt($modulo_vetor1*$modulo_vetor2);
				if($divisor!=0)
					$similaridade /= $divisor;
				
				
				$this->define_similaridade($autor1["autor_id"],$autor2["autor_id"],$similaridade);
			}
		}
	}

	/* Calcula a similaridade entre os autores */
	public function calculaSimilaridadeLocal() {
		$query_autor1 = mysql_query('SELECT DISTINCT autor_id, instituicao_id FROM autor_publicacao_instituicao ORDER BY autor_id');
		while($autor1 = mysql_fetch_array($query_autor1)) {
			$query_autor2 = mysql_query('SELECT DISTINCT autor_id, instituicao_id FROM autor_publicacao_instituicao WHERE autor_id > '.$autor1["autor_id"].' ORDER BY autor_id');
			while($autor2 = mysql_fetch_array($query_autor2)) {
				$modulo_vetor1 = 0;
				$modulo_vetor2 = 0;
				$similaridade = 0;
				$modV2_calculado = false;
				
				$query_pubAutor1 = mysql_query('SELECT * FROM '.$this->configDB->tabelaImportanciaAutorTema.' WHERE id_autor='.$autor1["autor_id"]);
				while($pubAutor1 = mysql_fetch_array($query_pubAutor1)) {
					$modulo_vetor1 += pow($pubAutor1["importancia"],2);
					
					$query_pubAutor2 = mysql_query('SELECT * FROM '.$this->configDB->tabelaImportanciaAutorTema.' WHERE id_autor='.$autor2["autor_id"]);
					while($pubAutor2 = mysql_fetch_array($query_pubAutor2)) {
						if($modV2_calculado == false) {
							 $modulo_vetor2 += pow($pubAutor2["importancia"],2);
						}
						
						if($pubAutor1["id_tema"] == $pubAutor2["id_tema"]) {
							 $similaridade += $pubAutor1["importancia"] * $pubAutor2["importancia"];
							 
							 if($modV2_calculado == true)
								break;
						}	
					}
					$modV2_calculado = true;
				}
				
				$divisor = sqrt($modulo_vetor1*$modulo_vetor2);
				if($divisor!=0)
					$similaridade /= $divisor;
				
				
				$this->define_similaridade_local($autor1["autor_id"], $autor1["instituicao_id"], $autor2["autor_id"], $autor2["instituicao_id"], $similaridade);
			}
		}
	}

	/* Recomenda autores que não possuem similaridade, mas que possuem influencia da localidade */
	public function recomendaConsiderandoLocalidade() {

		//$sql_aux = msql_query('ALTER TABLE '.$this->configDB->tabelaRecomendacaoLocal.' ADD `importancia` float;') or die(mysql_error());  

		$sucesso = TRUE;

		$query_autor1 = mysql_query('SELECT DISTINCT autor_id, instituicao_id FROM autor_publicacao_instituicao ORDER BY autor_id');

		while($autor1 = mysql_fetch_array($query_autor1)) {

			$query_autor2 = mysql_query('SELECT DISTINCT autor_id, instituicao_id FROM autor_publicacao_instituicao WHERE autor_id > '.$autor1["autor_id"].' ORDER BY autor_id');

			while($autor2 = mysql_fetch_array($query_autor2)) {
				
				//Verificar se não já foi recomendado
				$verifica = mysql_query('SELECT * FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1='.$autor1["autor_id"].' AND autor2='.$autor2["autor_id"]) or die(mysql_error());

				$importancia = $this->recupera_importancia_loc($autor1["autor_id"], $autor2["instituicao_id"]);

				if((mysql_num_rows($verifica) == 0) && ($importancia != 0))			
				{
					$sucesso &= mysql_query('INSERT INTO '.$this->configDB->tabelaRecomendacaoLocal.' (autor1, instituicao1, autor2, instituicao2, cooperacao, similaridade, importancia) VALUES ('.$autor1["autor_id"].', '.$autor1["instituicao_id"].', '.$autor2["autor_id"].', '.$autor2["instituicao_id"].', 0, 0, '.$importancia.')');
				}
			}
		}
	}


	public function verificaSeCooperouComCoautor()
	{
		$sucesso = TRUE;

		$query_autor1 = mysql_query('SELECT DISTINCT autor1 FROM '.$this->configDB->tabelaRecomendacaoLocal.' ORDER BY autor1');
		while($autor1 = mysql_fetch_array($query_autor1)) 
		{
			//Cada autor2 é um autor que foi recomendado a um autor1, mas nunca houve cooperação entre eles
			$query_autor2 = mysql_query('SELECT DISTINCT autor2 FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1 = '.$autor1["autor1"].' AND (similaridade > 0 OR importancia > 0) AND cooperacao = 0 ORDER BY autor2') or die(mysql_error());

			while($autor2 = mysql_fetch_array($query_autor2)) 
			{
				//Cada autor3 é um autor que já cooperou com o autor1
				$query_autor3 = mysql_query('SELECT DISTINCT autor2, cooperacao FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1 = '.$autor1["autor1"].' AND cooperacao > 0 ORDER BY autor1');

				$coop=0;

				//Verificar se o autor2 cooperou com algum autor3
				while($autor3 = mysql_fetch_array($query_autor3)) 
				{
					$query_aux = mysql_query('SELECT autor1,autor2 FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1 = '.$autor2["autor2"].' AND autor2 = '.$autor3["autor2"].' AND cooperacao > 0 ORDER BY autor1');

					if(mysql_num_rows($query_aux) > 0)
					{

						$coop=$coop+0.1;

						$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET cooperoucoautor = '.$coop.' WHERE autor1 = '.$autor1["autor1"].' AND autor2 = '.$autor2["autor2"]);
				

						if($sucesso!=true)
						    throw new Exception('Erro ao calcular a cooperacao: <em>'.mysql_error().'</em>.');
					}
				}
				

			}

		}

	}



	
    /* Calcula a corelação de todos os autores e salva no banco */
	public function calculaCorelacao() {
		$this->calculaImportanciaAutorTema();
		$this->calculaSimilaridade();  //Similaridade é igual a correlação
    }




    public function geraRecomendacaoIndividual() {
       	
	//Identifica as recomendações para criação de colaboração
    	/*if(!mysql_query('CREATE VIEW recomenda_nova_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao=0 
    								AND similaridade > 1/3 ORDER BY similaridade DESC'))
			throw new Exception('Erro ao criar a View para identificar as recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');*/

	    if(!mysql_query('CREATE VIEW recomenda_nova_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao=0 
    								AND (((1*similaridade)+(100*proximidade_social))/(1+100)) > 2/3 ORDER BY (((1*similaridade)+(100*proximidade_social))/(1+100)) DESC'))
			throw new Exception('Erro ao criar a View para identificar as recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');

       //Testando recomendações só com a similaridade
       /*if(!mysql_query('CREATE VIEW recomenda_nova_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao=0 
    								AND similaridade > 0 ORDER BY similaridade DESC'))
			throw new Exception('Erro ao criar a View para identificar as recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');*/
	
	
    	// Identifica as recomendacoes de intensificacao de colaboracao
	if(!mysql_query('CREATE VIEW recomenda_itensificar_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao > 0 AND (
    									(similaridade > 2/3 AND cooperacao <= 2/3) OR 
    									(similaridade > 1/3 AND similaridade <=2/3 AND cooperacao <=1/3)
    								) ORDER BY cooperacao/similaridade'))
			throw new Exception('Erro ao criar a View para identificar as recomendacoes de itensificacao de colaboracao: <em>'.mysql_error().'</em>.');


	// Identifica as "não recomendações" (colaboração ja esta ok)
	if(!mysql_query('CREATE VIEW recomenda_nao_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao > 0 AND (
    									(similaridade <= 1/3) OR 
    									(similaridade > 1/3 AND similaridade <= 2/3 AND cooperacao > 1/3) OR 
    									(similaridade > 2/3 AND cooperacao > 2/3)
    								) ORDER BY p1.nome'))
			throw new Exception('Erro ao criar a View para identificar as nao recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');	

    	
    }


    public function geraRecomendacaoIndividualLocalizacao() {
       	
	//Identifica as recomendações para criação de colaboração

	if(!mysql_query('CREATE VIEW recomenda_nova_colaboracao_loc3 AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, importancia FROM '.
    								$this->configDB->tabelaRecomendacaoLocal.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao = 0 AND ( (((1*importancia)+(225*proximidade_social))/(1+225))  > 2/3) AND (p1.nome != p2.nome) ORDER BY (((1*importancia)+(225*proximidade_social))/(1+225)) DESC'))
			throw new Exception('Erro ao criar a View para identificar as recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');
	
       
	/* NÃO PRECISA RECOMENDAR INTENSIFICAR - VERIFICAR TODOS OS ARQUVIOS QUE CHAMAM ALGUMA DAS VIEWS ABAIXO E REMOVER */
       
    	// Identifica as recomendacoes de intensificacao de colaboracao
	/*if(!mysql_query('CREATE VIEW recomenda_itensificar_colaboracao_loc AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, ial.importancia FROM '.
    								$this->configDB->tabelaRecomendacaoLocal.' INNER JOIN '.$this->configDB->tabelaImportanciaAutorLocalizacao.' ial ON autor1 = ial.id_autor INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE ial.id_instituicao = instituicao2 AND cooperacao > 0 AND (
    									(similaridade > 2/3 AND cooperacao <= 2/3 AND ial.importancia <= 2/3) OR 
    									(similaridade > 1/3 AND similaridade <=2/3 AND cooperacao <=1/3 AND ial.importancia <= 1/3)
    								) ORDER BY cooperacao/similaridade'))
			throw new Exception('Erro ao criar a View para as recomendacoes de itensificacao de colaboracao: <em>'.mysql_error().'</em>.');

	if(!mysql_query('CREATE VIEW recomenda_itensificar_colaboracao_loc2 AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, importancia FROM '.
    								$this->configDB->tabelaRecomendacaoLocal.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao > 0 AND (
    									(similaridade > 2/3 AND cooperacao <= 2/3) OR
									(importancia > 2/3 AND cooperacao <= 2/3) OR 
    									(similaridade > 1/3 AND similaridade <=2/3 AND cooperacao <=1/3) OR 	
								        (importancia > 1/3 AND importancia <=2/3 AND cooperacao <=1/3)
    								) ORDER BY cooperacao/similaridade'))
			throw new Exception('Erro ao criar a View para as recomendacoes de itensificacao de colaboracao: <em>'.mysql_error().'</em>.');*/


	// Identifica as "não recomendações" (colaboração ja esta ok)
	/*if(!mysql_query('CREATE VIEW recomenda_nao_colaboracao AS SELECT p1.nome AS nome1, p2.nome AS nome2, similaridade, cooperacao FROM '.
    								$this->configDB->tabelaRecomendacao.' INNER JOIN '.$this->configDB->tabelaAutor.' a ON autor1 = a.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p1 ON a.pesquisador_id = p1.id  INNER JOIN '.$this->configDB->tabelaAutor.' b ON autor2 = b.id INNER JOIN '.$this->configDB->tabelaPesquisador.' p2 ON b.pesquisador_id = p2.id WHERE cooperacao > 0 AND (
    									(similaridade <= 1/3) OR 
    									(similaridade > 1/3 AND similaridade <= 2/3 AND cooperacao > 1/3) OR 
    									(similaridade > 2/3 AND cooperacao > 2/3)
    								) ORDER BY p1.nome'))
			throw new Exception('Erro ao criar a View para identificar as nao recomendacoes de colaboracao: <em>'.mysql_error().'</em>.');*/	

    	
    }

}

?>
