<?php
class configDB 
{
	public $id;
	public $tabelaAuto;
	public $tabelaTema;
	public $tabelaInstituicao;
	public $tabelaPublicacao;
	public $tabelaPesquisador;
	public $tabelaAutorPublicacao;
	public $viewGrafoGeral;
    	public $tabelaRecomendacao;
    	public $tabelaRecomendacaoLocal;
	public $tabelaImportanciaAutorTema;
	public $tabelaImportanciaAutorLocalizacao;
	public $tabelaAssociacaoPesquisadorInstituicao;
	public $tabelaColaboracaoGabarito;
	public $tabelaColaboracaoGabaritoItensificacao;
        public $tabelaareaPesquisa;
        public $tabelaareaPesquisaPesquisador;

	/* Faz a conexao com o banco de dados
	*/
	public function conecta($host,$user,$pass,$base) 
	{
		if(!mysql_connect($host,$user,$pass))
			throw new Exception('Erro ao conectar com o banco de dados: <em>'.mysql_error().'</em>.');
		
		if(!mysql_select_db($base))
			throw new Exception('Erro ao selecionar a base de dados: <em>'.mysql_error().'</em>.');
	}


	public function createTables()
	{
		$sql1 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaAutorPublicacao.'` (
				  `id_autor` int(10) unsigned NOT NULL,
				  `id_publicacao` int(10) unsigned NOT NULL,
				  PRIMARY KEY (`id_autor`,`id_publicacao`)
				) ENGINE=MyISAM DEFAULT CHARSET=latin1;';

		$sql2 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaAutor.'` (
				  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
				  `nome` varchar(50) NOT NULL,
				  `id_instituicao` int(10) unsigned NOT NULL,
				  PRIMARY KEY (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;';

		$sql3 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaPublicacao.'` (
				  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
				  `ano` year(4) NOT NULL,
				  `titulo` varchar(50) NOT NULL,
				  `id_tema` int(10) unsigned NOT NULL,
				  PRIMARY KEY (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;';

		$sql4 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaTema.'` (
				  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
				  `nome` varchar(50) NOT NULL,
				  PRIMARY KEY (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;';

		$sql5 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaRecomendacao.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `autor1` int(10) unsigned NOT NULL,
		          `autor2` int(10) unsigned NOT NULL,
		          `cooperacao` float DEFAULT NULL,
		          `similaridade` float DEFAULT NULL,
			  `menor_caminho` float DEFAULT NULL,
			  `proximidade_social` float DEFAULT NULL,
		          `aspc_temporal` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `autor1` (`autor1`),
		          KEY `autor2` (`autor2`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

        
		$sql6 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaImportanciaAutorTema.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `id_autor` int(10) unsigned NOT NULL,
		          `id_tema` int(10) unsigned NOT NULL,
		          `importancia` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `id_autor` (`id_autor`),
		          KEY `id_tema` (`id_tema`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql7 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaInstituicao.'` (
				  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
				  `nome` varchar(50) NOT NULL,
				  PRIMARY KEY (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=latin1 ;';


		$sql8 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaRecomendacaoLocal.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `autor1` int(10) unsigned NOT NULL,
			  `instituicao1` int(10) unsigned,	
		          `autor2` int(10) unsigned,
			  `instituicao2` int(10) unsigned,	
			  `cooperacao` float DEFAULT NULL,
			  `distancia` float DEFAULT NULL,
			  `importancia` float DEFAULT NULL,
  		          `similaridade` float DEFAULT NULL,
       			  `menor_caminho` float DEFAULT NULL,
    		          `proximidade_social` float DEFAULT NULL,
		          `aspc_temporal` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `autor1` (`autor1`),
		          KEY `autor2` (`autor2`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';


		$sql9 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaImportanciaAutorLocalizacao.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `id_autor` int(10) unsigned NOT NULL,
		          `id_instituicao` int(10) unsigned NOT NULL,
		          `importancia` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `id_autor` (`id_autor`),
		          KEY `id_instituicao` (`id_instituicao`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql10 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaColaboracaoGabarito.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `autor1` int(10) unsigned NOT NULL,
       			  `instituicao1` int(10) unsigned,
		          `autor2` int(10) unsigned NOT NULL,
                          `instituicao2` int(10) unsigned,
			  `similaridade` float DEFAULT NULL,
			  `importancia` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `autor1` (`autor1`),
		          KEY `autor2` (`autor2`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql11 = 'CREATE TABLE IF NOT EXISTS recomenda_nova_colaboracao_loc_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql12 = 'CREATE TABLE IF NOT EXISTS recomenda_nova_colaboracao_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

	        $sql13 = 'CREATE TABLE IF NOT EXISTS recomenda_itensificar_colaboracao_loc_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql14 = 'CREATE TABLE IF NOT EXISTS recomenda_itensificar_colaboracao_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql15 = 'CREATE TABLE IF NOT EXISTS `'.$this->tabelaColaboracaoGabaritoItensificacao.'` (
		          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		          `autor1` int(10) unsigned NOT NULL,
       			  `instituicao1` int(10) unsigned,
		          `autor2` int(10) unsigned NOT NULL,
                          `instituicao2` int(10) unsigned,
			  `similaridade` float DEFAULT NULL,
			  `importancia` float DEFAULT NULL,
		          PRIMARY KEY (`id`),
		          KEY `autor1` (`autor1`),
		          KEY `autor2` (`autor2`)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';


		$sql16 = 'CREATE TABLE IF NOT EXISTS recomenda_nova_colaboracao_loc2_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql17 = 'CREATE TABLE IF NOT EXISTS recomenda_nova_colaboracao_loc3_deduplicada(
			  `nome1` varchar(90) NOT NULL,			  
			  `nome2` varchar(90) NOT NULL,
			  KEY `nome1` (`nome1`),
		          KEY `nome2` (`nome2`)		  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

		$sql18 = 'CREATE TABLE IF NOT EXISTS autor_publicacao_instituicao(
			  `autor_id` int(10) unsigned NOT NULL,			  
			  `inct_id` int(10) unsigned NOT NULL,
			  `instituicao_id` int(10) unsigned NOT NULL,
			  `publicacao_id` int(10) unsigned NOT NULL	  
                          ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';


		$sql19 = 'CREATE TABLE IF NOT EXISTS cooperacao_agrupada_instituicao(
			  `instituicao1` int(10) unsigned,	
		   	  `instituicao2` int(10) unsigned,	
			  `cooperacao` float DEFAULT NULL,
			  `temp_desloc` float DEFAULT NULL
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

                $sql20 = 'CREATE TABLE IF NOT EXISTS areaPesquisa(
			  `nome` varchar(250)
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';

                $sql21 = 'CREATE TABLE IF NOT EXISTS areaPesquisaPesquisador(
			  `pesquisador_id` int(15) unsigned,
                          `area_id` int(15) unsigned
		        ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;';


		
		if(!mysql_query($sql1))
				throw new Exception('Erro ao criar tabela autorPub: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql2))
				throw new Exception('Erro ao criar tabela autor: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql3))
			throw new Exception('Erro ao criar tabela publicacao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql4))
			throw new Exception('Erro ao criar tabela tema: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql5))
			throw new Exception('Erro ao criar tabela recomendacao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql6))
			throw new Exception('Erro ao criar tabela importanciaAutorTema: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql7))
			throw new Exception('Erro ao criar tabela instituicao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql8))
			throw new Exception('Erro ao criar tabela recomendacaoLocal: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql9))
			throw new Exception('Erro ao criar tabela importanciaAutorLocalizacao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql10))
			throw new Exception('Erro ao criar tabela colaboracao_gabarito: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql11))
			throw new Exception('Erro ao criar tabela recomenda_nova_colaboracao_loc_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql12))
			throw new Exception('Erro ao criar tabela recomenda_nova_colaboracao_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql13))
			throw new Exception('Erro ao criar tabela recomenda_itensificar_colaboracao_loc_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql14))
			throw new Exception('Erro ao criar tabela recomenda_itensificar_colaboracao_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql15))
			throw new Exception('Erro ao criar tabela colaboracao_gabarito_itensificacao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql16))
			throw new Exception('Erro ao criar tabela recomenda_nova_colaboracao_loc2_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql17))
			throw new Exception('Erro ao criar tabela recomenda_nova_colaboracao_loc3_deduplicada: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql18))
			throw new Exception('Erro ao criar tabela autor_publicacao_instituicao: <em>'.mysql_error().'</em>.');
		if(!mysql_query($sql19))
			throw new Exception('Erro ao criar tabela cooperacao_agrupada_instituicao: <em>'.mysql_error().'</em>.');
                if(!mysql_query($sql20))
			throw new Exception('Erro ao criar tabela areaPesquisa: <em>'.mysql_error().'</em>.');
                if(!mysql_query($sql21))
			throw new Exception('Erro ao criar tabela areaPesquisaPesquisador: <em>'.mysql_error().'</em>.');




    }


}
?>
