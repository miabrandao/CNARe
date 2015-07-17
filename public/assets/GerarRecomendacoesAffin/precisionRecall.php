<?php
class precisionRecall 
{

	private $configDB;
	
	function __construct($configDB) {
		$this->configDB = $configDB;
	}

    //Se A é recomendado a B, então B será recomendado a A. Por isso, se já existe o par (A,B), nós removemos o par (B,A).
	//Entretanto, precisamos alterar isso de forma que os pesos sejam analisados separadamente. Por exemplo, B só será recomendado a A se houver pesos nessa relação e vice-versa.
	public function deduplicar()
	{
	
		$query = mysql_query('SELECT nome1, nome2 FROM recomenda_nova_colaboracao_loc3');
		
		while($fetch = mysql_fetch_array($query)) 
		{						
			$query_aux = mysql_query('SELECT nome1, nome2 FROM recomenda_nova_colaboracao_loc3_deduplicada WHERE nome1 LIKE "'.$fetch["nome2"].'" and nome2 LIKE "'.$fetch["nome1"].'"');

			if(mysql_num_rows($query_aux) == 0)
			{
				if(!mysql_query('INSERT INTO recomenda_nova_colaboracao_loc3_deduplicada(nome1, nome2) VALUES ("'.$fetch["nome1"].'", "'.$fetch["nome2"].'")'))
					throw new Exception('Erro ao inserir na tabela recomenda_nova_colaboracao_loc3_deduplicada: <em>'.mysql_error().'</em>.');	
			}
		}

	}


}
?>
