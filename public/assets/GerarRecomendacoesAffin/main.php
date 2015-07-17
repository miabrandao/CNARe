<?php

/* Como o __autoload nao funciona no wiki eh preciso fazer os includes abaixo */
include_once("configDB.php");
include_once("geraVisGlobal.php");
include_once("recomendacao.php");
include_once("shortest_path.php");
include_once("shortest_path_local.php");
include_once("precisionRecall.php");


try {
	/* Define as configuracoes e cria as tabelas do banco de dados */
	$configDB = new configDB();
	$configDB->conecta("localhost","root","53221554","cnare_development");
	$configDB->tabelaAutor = 'autor';
	$configDB->tabelaPesquisador = 'pesquisador';
	$configDB->tabelaTema = 'area_conhecimento';
        $configDB->tabelaareaPesquisa = 'areaPesquisa';
        $configDB->tabelaareaPesquisaPesquisador = 'areaPesquisaPesquisador';
	$configDB->tabelaPublicacao = 'publicacao';
	$configDB->tabelaAutorPublicacao = 'autoria_autor_publicacao';
	$configDB->viewGrafoGeral = 'viewGrafoGeral';
    $configDB->tabelaRecomendacao = 'recomendacao';
    $configDB->tabelaRecomendacaoLocal = 'recomendacao_local';
    $configDB->tabelaImportanciaAutorTema = 'importancia_autor_tema';
	$configDB->tabelaInstituicao = 'instituicao';
	$configDB->tabelaAssociacaoPesquisadorInstituicao = 'associacao_pesquisador_instituicao';
    $configDB->tabelaImportanciaAutorLocalizacao = 'importancia_autor_localizacao';
    $configDB->tabelaColaboracaoGabarito = 'colaboracao_gabarito';
	$configDB->tabelaColaboracaoGabaritoItensificacao = 'colaboracao_gabarito_itensificacao';


	$configDB->createTables();

	/* Gera a VIsualizacao Global e de evolucao da Rede */
	$visGLobal = new geraVisGlobal($configDB);
        print "criaViewCache()...";
	$visGLobal->criaViewCache();

	$recomendacao = new recomendacao($configDB);
        print "calculaCooperacao()...";
        $recomendacao->calculaCooperacao();
        //print "calculaCorelacao()...";
        //$recomendacao->calculaCorelacao();
        print "define_importancia_localidade()...";
        $recomendacao->define_importancia_localidade();
        print "calculaImportanciaAutorLocalizacao()...";
	$recomendacao->calculaImportanciaAutorLocalizacao();
        print "calculaSimilaridadeLocal()...";
	$recomendacao->calculaSimilaridadeLocal();


	//Calcula cooperacao absoluta
        //print "calculaCooperacaoAbsoluta()...";
        //$recomendacao->calculaCooperacaoAbsoluta();
	
	//Calcula cooperacao agrupada por instituição
        //print "calculaCooperacaoAgrupandoInstituicao()...";
	//$recomendacao->calculaCooperacaoAgrupandoInstituicao();


	//Define a métrica de proximidade social
	//$sp = new shortest_path($configDB);
        //print "define_shortest_path()...";
	//$sp->define_shortest_path();

	$splocal = new shortest_path_local($configDB);
        print "define_shortest_path()...";
	$splocal->define_shortest_path();

                                                                                                                  
	//Gera as recomendações
        #print "geraRecomendacaoIndividual()...";
	#$recomendacao->geraRecomendacaoIndividual();
        print "geraRecomendacaoIndividualLocalizacao()...";
        $recomendacao->geraRecomendacaoIndividualLocalizacao();


	//Deduplica e calcula a precisão e revocação.
	$precision_recall = new precisionRecall($configDB);
        print "deduplicar()...";
	$precision_recall->deduplicar();

      

	$sucesso = true;

} catch(Exception $e) {
	echo 'ERRO: ',  $e->getMessage(), "<br />";
}

?>
