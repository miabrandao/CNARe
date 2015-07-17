class MoreResearchersController < ApplicationController

  def insert
    #Número da página
    @here = 4
    #Desmarcando pesquisadores
    Pesquisador.update_all('selecao = 0')
    #filtro?
    @filter = session[:filter_insert]
    #filtro quantidade
    if session[:amount_insert].nil?
      @amount = "1"
    else
      @amount = session[:amount_insert]
    end
    #filtro ano
    if session[:year_insert].nil?
      @year = "1"
    else
      @year = session[:year_insert]
    end
    #filtro instituicao
    if session[:institution_insert].nil?
      @institution = "1"
    else
      @institution = session[:institution_insert]
    end
    if @filter == "false"
      @amount = "1"
      @year = "1"
      @institution = "1"
    end
    #Métrica selecionada
    @metric = session[:metric]
    #Inicializando as variáveis utilizadas na view, ambas são úteis para controlar quais forms e botões serão impressos...
    @bot_submit = false
    #Coletando o id do pesquisador consultado...
    @researchers = session[:id]
    #Marcando pesquisadores
    Pesquisador.where('id = ?', @researchers).update_all('selecao = 1')
    #Inicializando lista de coautores em comum...
    @common = []
    #Pesquisador alvo selecionado
    @target = session[:pesquisador_id_insert]
    #Lista de Pesquisadores que não serão selecionáveis
    @nodes_lista = Pesquisador.select("id").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) )", @researchers)
    @nodes_lista = @nodes_lista | @researchers
    if @researchers and @target and @target != "" 
      #lista de instituições selecionáveis no filtro 
      @instituicoes = []
      @instituicoes_source = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @researchers, @researchers)
      @instituicoes_target = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @target, @target)
      @instituicoes = @instituicoes | @instituicoes_source
      @instituicoes = @instituicoes | @instituicoes_target
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
      #Buscando os nós dos coautores do pesquisador consultado...
      @nodes_researcher = Pesquisador.select("distinct nome as name, id, instituicao").where("(#{@institution} OR id = ?) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( link.target <> ? ) AND ( #{@amount} ) AND ( #{@year} ))", @researchers, @researchers, @target)
      #Buscando os nós dos coautores do pesquisador inserido...
      @nodes_target = Pesquisador.select("distinct nome as name, id, instituicao").where("(#{@institution} OR id = ?) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( link.target <> ? ) AND ( #{@amount} ) AND ( #{@year} ))", @target, @target, @researchers)
      #Encontrando os coautores em comum... 
      for id in @nodes_researcher.map(&:id)
        for id2 in @nodes_target.map(&:id)
          if id == id2
            @common.push id
          end
        end
      end 
      @nodes_common = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id in (?)", @common)
      #Lista de Pesquisadores que não serão selecionáveis
      @nodes_lista = @nodes_researcher.map(&:id)
      @nodes_Lista = @nodes_Lista | @researchers
      #Adicionando o nó do pesquisador consultado...
      @nodes_researcher_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @researchers)
      @nodes_researcher = @nodes_researcher | @nodes_researcher_aux
      #Adicionando o nó do pesquisador inserido...
      @nodes_target_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @target) 
      @nodes_target = @nodes_target | @nodes_target_aux 
      #Lista de recomendações
      @recommendedlink = []
      if session[:button_insert] == "Affin"
        @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as value, value as classificacao").where("(pesquisador1_id = ? and pesquisador2_id in (?)) AND metodo_id = 2", @researchers, @nodes_target).order('value DESC').limit(5)  
      elsif session[:button_insert] == "Corals"
        @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as value, value as classificacao").where("(pesquisador1_id = ? and pesquisador2_id in (?)) AND metodo_id = 3", @researchers, @nodes_target).order('value DESC').limit(5) 
      end  
      #Excluindo da lista de nós das redes de coautoria, os nós dos pesquisadores em comum...
      if @common.any?
        @nodes_researcher = @nodes_researcher.reject { |h| @common.include? h['id'] }
        @nodes_target = @nodes_target.reject { |h| @common.include? h['id'] }
      end 
      #Marcando pesquisadores
      Pesquisador.where('id = ?', @target).update_all('selecao = 1')
      #Determinando a cor dos nós através da coluna group...
      if @common.any?
        @nodes_common.each_with_index do |item, index|
          item.group = 3
        end
      end
      @nodes_researcher.each_with_index do |item, index|
        item.group = 1
      end
      @nodes_target.each_with_index do |item, index|
        item.group = 2
      end 
      #Unindo todos os nós em uma única lista...
      @nodes = []
      @nodes = @nodes | @nodes_researcher
      @nodes = @nodes | @nodes_target
      @nodes = @nodes | @nodes_common 
      #Coeficiente de agrupamento
      @vizinhos_antes_id = Pesquisador.select("id").where("(#{@institution} OR id = ?) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( link.target <> ? ) AND ( #{@amount} ) AND ( #{@year} ))", @researchers, @researchers, @target).map(&:id)
      @arestas_vizinhos_antes = Link.select("source, target").where("source in (?) AND target in (?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})", @vizinhos_antes_id, @vizinhos_antes_id) 
      @clustering_antes = (@arestas_vizinhos_antes.size/2).to_f/((@vizinhos_antes_id.size*(@vizinhos_antes_id.size - 1))/2).to_f
      @vizinhos_depois_id = @vizinhos_antes_id | @recommendedlink.map(&:target)
      @arestas_vizinhos_depois = Link.select("source, target").where("source in (?) AND target in (?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})", @vizinhos_depois_id, @vizinhos_depois_id)
      @clustering_depois = (@arestas_vizinhos_depois.size/2).to_f/((@vizinhos_depois_id.size*(@vizinhos_depois_id.size - 1))/2).to_f
      #homofilia
      @inst_pesquisador = AssociacaoPesquisadorInstituicao.select('instituicao_id').where('pesquisador_id = ?', @researchers).map(&:instituicao_id).first
      @homofilia_antes = AssociacaoPesquisadorInstituicao.count(:conditions => ['pesquisador_id in (?, ?) AND instituicao_id = ?', @nodes_researcher, @nodes_common, @inst_pesquisador])
      @homofilia_antes = (@homofilia_antes - 1).to_f / ((@nodes_researcher.size - 1).to_f + (@nodes_common.size).to_f)
      @homofilia_depois = AssociacaoPesquisadorInstituicao.count(:conditions => ['pesquisador_id in (?, ?, ?) AND instituicao_id = ?', @nodes_researcher, @nodes_common, @recommendedlink.map(&:target), @inst_pesquisador])
      @homofilia_depois = (@homofilia_depois - 1).to_f / ((@nodes_researcher.size - 1).to_f + (@nodes_common.size).to_f + (@recommendedlink.size).to_f)
      #Buscando os links...
      if @metric == "1"
        @links = Link.select("source, target, value, count_pub_target as count").where("source in (?) AND target in (?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})", @nodes.map(&:id), @nodes.map(&:id)) 
      else
        @links = Link.select("source, target, value, count_pub_target as count").where("source in (?, ?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})", @researchers, @target) 
      end
      #Carregando a lista de pesquisadores...
      @pesquisadores = Pesquisador.where("id not in (?)", @nodes_researcher.map(&:id)).order(:nome) 
    elsif @researchers and (@target.nil? or @target == "")
      #lista de instituições selecionáveis no filtro 
      @instituicoes = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @researchers, @researchers)
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
      #Montando o grafo...
      @links = Link.select("source, target, `value`, count_pub_target as count").where("source = ? AND (#{@amount}) AND (#{@year}) AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})
", @researchers)
      @nodes = Pesquisador.select("distinct nome as name, id, instituicao").where("(#{@institution} OR id = ?) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?) AND (#{@amount}) AND (#{@year}))", @researchers, @researchers, @researchers) 
      #Carregando a lista de pesquisadores...
      @pesquisadores = Pesquisador.where("id not in (?)", @nodes_lista).order(:nome)
      #Lista de recomendações
      @recommendedlink = []     
    end
    if @target and @target != ""
      @bot_submit = true
    end
    respond_to do |format|
       format.html  
       format.json { render :json => {:Nodes => @nodes, :Links => @links, :RecommendedLink => @recommendedlink}}
    end
  end

  def load_insert
    #Descartando as sessões do pesquisador selecionado anteriormente
    session[:filter_insert] = nil
    session[:amount_insert] = nil
    session[:year_insert] = nil
    session[:institution_insert] = nil
    session[:button_insert] = nil
    #Buscando o id do pesquisador selecionada...
    session[:pesquisador_id_insert] = params[:select_researcher_insert]
    redirect_to url_for(:action => :insert)
  end

  def filter_insert
    #filtro?
    if params[:filter_insert]
      session[:filter_insert] = params[:filter_insert]
    end
    #filtro quantidade
    if params[:amount_insert] == ""
      session[:amount_insert] = "1"
    else
      session[:amount_insert] = params[:amount_insert]
    end
    #filtro ano
    if params[:year_insert] == ""
      session[:year_insert] = "1"
    else
      session[:year_insert] = params[:year_insert]
    end
    #filtro instituicao
    if params[:institution_insert] == ""
      session[:institution_insert] = "1"
    else
      session[:institution_insert] = params[:institution_insert]
    end
    if params[:institution_insert] == "" and params[:year_insert] == "" and params[:amount_insert] == ""
      session[:filter_insert] = "false"
    end
    redirect_to url_for(:action => :insert)
  end

  def generate_rec_insert
    session[:button_insert] = params[:commit_insert]
    #Preparando o banco de dados para a geração das recomendações...
    system('python ' + (Rails.root).to_s + '/public/assets/Preparacao.py')
    if params[:commit_insert] == "Affin"
      #Gerando as recomendações...
      system('php ' + (Rails.root).to_s + '/public/assets/GerarRecomendacoesAffin/main.php')
      #Inserindo as recomendacoes...
      system('python ' + (Rails.root).to_s + '/public/assets/InsereRecomendacoesAffin.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
    elsif params[:commit_insert] == "Corals"
      #Gerando as recomendações...
      system('php ' + (Rails.root).to_s + '/public/assets/GerarRecomendacoesCorals/main.php')
      #Inserindo as recomendacoes...
      system('python ' + (Rails.root).to_s + '/public/assets/InsereRecomendacoesCorals.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
    end
    #Limpando banco de dados(exclui as tabelas e as views geradas pelo algoritmo de geração das recomendações)...
    system('python ' + (Rails.root).to_s + '/public/assets/LimpaBanco.py')
    redirect_to url_for(:action => :insert)
  end

  def define_metric
    session[:metric] = params[:select_metrics]
    redirect_to url_for(:action => :insert)
  end

  def update_network
    @researchers = session[:id]
    @selected_researcher = session[:pesquisador_id_insert] 
    if params[:insert_update] 
      #Selecionando pesquisador para a atualização da sua rede...
      Pesquisador.where("id = ? OR id = ?", @selected_researcher, @researchers).update_all("sel_update = 1")
      #Gerando as novas colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/NewCollaborations.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
      #Desmarcando pesquisador...
      Pesquisador.where("id = ? OR id = ?", @selected_researcher, @researchers).update_all("sel_update = NULL")
      redirect_to url_for(:action => :insert), notice: "Networks updated." 
    end
  end

  def import_data_insert
    verifica_pesquisador = 3
    verifica_publicacao = 3
    #Inserindo um novo pesquisador...
    if params[:insert_researcher]
      verifica_pesquisador = PesquisadorAux.import(params[:insert_researcher])
      system('python ' + (Rails.root).to_s + '/public/assets/InserePesquisador.py')
    end
    #Inserindo novas publicações...
    if params[:insert_publications]
      verifica_publicacao = PublicacaoAux.import(params[:insert_publications])
      system('python ' + (Rails.root).to_s + '/public/assets/InserePublicacoes.py')
    end
    #Excluindo pesquisadores e publicacoes inseridos anteriormente da tabela auxiliar...
    PesquisadorAux.destroy_all
    PublicacaoAux.destroy_all
    if verifica_pesquisador != 0 and verifica_publicacao != 0 
      if verifica_pesquisador == 3 and verifica_publicacao == 3 
        redirect_to url_for(:action => :insert)
      else
        redirect_to url_for(:action => :insert), notice: "Publications and/or researcher imported."
      end
    elsif verifica_pesquisador != 0  and verifica_publicacao == 0
      redirect_to url_for(:action => :insert), :flash => { :error => "Unknown #{params[:insert_publications].original_filename} type" }
    elsif verifica_pesquisador == 0 and verifica_publicacao != 0
      redirect_to url_for(:action => :insert), :flash => { :error => "Unknown #{params[:insert_researcher].original_filename} type" }
    elsif verifica_pesquisador == 0 and verifica_publicacao == 0
      redirect_to url_for(:action => :insert), :flash => { :error => "Unknown #{params[:insert_researcher].original_filename} and #{params[:insert_publications].original_filename} types" }
    end
  end

end
