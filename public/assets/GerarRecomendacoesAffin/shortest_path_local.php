<?php

//Variável global para armazenar a proximidade social
$Sc = 0;

class shortest_path_local 
{
	private $configDB;
	private $node;
	private $edge;
	
	function __construct($configDB) {
		$this->configDB = $configDB;
	}

	//Função para definir a proximidade social entre pares de autores
	public function define_shortest_path()
	{
		//Instanciar as classes de nós e arestas
		$nodeList = array();

		$sucesso = true;

		$query = mysql_query('SELECT DISTINCT autor1, autor2, cooperacao FROM '.$this->configDB->tabelaRecomendacaoLocal.' ORDER BY autor1');
		$node_anterior1 = NULL;
		$node_anterior2 = NULL;

		//Inicializa uma lista de adjacência com os autores e as conexões entre eles
		while($fetch = mysql_fetch_array($query)) 
		{

			if($fetch["cooperacao"] != 0)
			{
				if(is_null($node_anterior1) || ($node_anterior1 != $fetch["autor1"]))
				{
					$nodeList[$fetch['autor1']] = array_merge($fetch, array('predecessor' => NULL), array('dist' => NULL), array('color' => 0), array('children' => array()));
					array_push($nodeList[$fetch['autor1']]['children'], $fetch['autor2']);
					$node_anterior1 = $fetch["autor1"];

				}
				else
				{
					array_push($nodeList[$fetch['autor1']]['children'], $fetch['autor2']);
				}

			}
			else
			{
				if(is_null($node_anterior1) || ($node_anterior1 != $fetch["autor1"]))
				{
					$nodeList[$fetch['autor1']] = array_merge($fetch, array('predecessor' => NULL), array('dist' => NULL), array('color' => 0), array('children' => array()));
					$node_anterior1 = $fetch["autor1"];

				}
							
			}

		}
	

		$query = mysql_query('SELECT DISTINCT autor1, autor2 FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE cooperacao = 0 ORDER BY autor1');	

		//Faz uma chamada a função que computa a proximidade social
		while($fetch = mysql_fetch_array($query)) 
		{
			//Armazena o peso do menor caminho no banco de dados
			$menor_cam = $this->shortest_path_between_authors($fetch["autor1"], $fetch["autor2"], $nodeList);

			if(!is_null($menor_cam))
			{
				$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET menor_caminho = '.$menor_cam.' WHERE autor1='.$fetch["autor1"].' AND autor2='.$fetch["autor2"]);
			}
			else
			{
				$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET menor_caminho = 0 WHERE autor1='.$fetch["autor1"].' AND autor2='.$fetch["autor2"]);
				$menor_cam = 0;

			}

			if($sucesso!=true)
	            		throw new Exception('Erro ao calcular o menor caminho: <em>'.mysql_error().'</em>.');

			echo "Proximidade social entre ".$fetch["autor1"]." - ".$fetch["autor2"].": ".$menor_cam."\n\n";
		}

			//Calcula e armazena a proximidade social no banco de dados
			$this->calcula_max();

	}

	//Função que implementa o algoritmo de busca em largura para calcular o caminho mínimo entre pares de autores
	private function shortest_path_between_authors($autor1, $autor2, $nodeList)
	{	
		global $Sc;
	
		$Q = array(1 => $autor1);
	
		while(!empty($Q))
		{
			$u = array_shift($Q);

			foreach($nodeList[$u]['children'] as $v)
			{

				if($nodeList[$v]['color'] == 0)
				{
					$nodeList[$v]['color'] = 1;
					$nodeList[$v]['predecessor'] = $u;

					//print_r($nodeList);
					$sql = mysql_query('SELECT cooperacao FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE autor1='.$u.' AND autor2='.$v);
	
					$result = mysql_fetch_array($sql);
					$nodeList[$v]['dist'] = (1 + (1 - $result["cooperacao"]));
					
					array_push($Q, $v);

					//echo "De ".$u." encontrou o destino: ".$v."\n";		

					if($v == $autor2)
					{
						//echo "De ".$u." encontrou o destino: ".$v." nivel ".$count."\n";		
						//echo "Caminho: \n\n";
						$Sc = 0;	
						$this->imprime_menor_caminho($nodeList, $autor1, $autor2);
						return $Sc;
					}

				}
			}

			$nodeList[$u]['color'] = 2;

		}


	}

	//Função que imprime o caminho mínimo e calcula a proximidade social entre um par de autores
	private function imprime_menor_caminho($nodeList, $autor1, $autor2)
	{
		global $Sc;

		if($autor1 == $autor2)
		{
			//echo $autor1;
		}
		elseif($nodeList[$autor2]['predecessor'] == NULL)
		{
			echo "Nao ha caminho de ".$autor1." para ".$autor2;
		}
		else
		{
			$Sc = $Sc + $nodeList[$autor2]['dist'];	
			$this->imprime_menor_caminho($nodeList, $autor1, $nodeList[$autor2]['predecessor']);
			//echo $autor2.' - '.$nodeList[$autor2]['dist'];
		}

		//echo "\n\n";

	}

	//Retorna o máximo menor caminho
	private function calcula_max()
	{
		$max = 0;
		$sucesso = true;
		
		$query = mysql_query('SELECT MAX(menor_caminho) as max_menor_caminho FROM '.$this->configDB->tabelaRecomendacaoLocal);	
		
		$max = mysql_result($query, 0);

		echo "\nMAX: ".$max."\n\n";

		$query = mysql_query('SELECT autor1, autor2, menor_caminho FROM '.$this->configDB->tabelaRecomendacaoLocal.' WHERE menor_caminho IS NOT NULL');

		while($fetch = mysql_fetch_array($query)) 
		{
			$proc_social = (($max + 1) - $fetch["menor_caminho"])/$max;

			if($fetch["menor_caminho"] != 0)
			{

				$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET proximidade_social = '.$proc_social.' WHERE autor1='.$fetch["autor1"].' AND autor2='.$fetch["autor2"]);

				if($sucesso!=true)
	            			throw new Exception('Erro ao calcular a proximidade social: <em>'.mysql_error().'</em>.');
			}
			else
			{
				$sucesso &= mysql_query('UPDATE '.$this->configDB->tabelaRecomendacaoLocal.' SET proximidade_social = 0 WHERE autor1='.$fetch["autor1"].' AND autor2='.$fetch["autor2"]);

				if($sucesso!=true)
	            			throw new Exception('Erro ao calcular a proximidade social: <em>'.mysql_error().'</em>.');
			}
		}

			
	}

}


?>
