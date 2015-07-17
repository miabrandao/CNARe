class NetworksController < ApplicationController

    def networks
    #Número da página
    @here = 5
    #Desmarcando pesquisadores
    Pesquisador.update_all('selecao = 0')
    #filtro?
    @filter = session[:filter_network]
    #filtro quantidade
    if session[:amount_network].nil?
      @amount = "1"
    else
      @amount = session[:amount_network]
    end
    #filtro ano
    if session[:year_network].nil?
      @year = "1"
    else
      @year = session[:year_network]
    end
    #filtro instituicao
    if session[:institution_network].nil?
      @institution = "1"
    else
      @institution = session[:institution_network]
    end
    if @filter == "false"
      @amount = "1"
      @year = "1"
      @institution = "1"
    end
    #Inicializando as variáveis utilizadas na view, ambas são úteis para controlar quais forms e botões serão impressos...
    @sel_researcher = false
    @bot_submit = false
    #Coletando o id do pesquisador consultado...
    @researchers = session[:id]
    #Exibindo redes existentes no banco
    @redes = Rede.order(:nome)
    #Id da rede selecionada
    @rede_id = session[:rede_id]  
    #Inicializando lista de coautores em comum...
    @common = [] 
    if @researchers 
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
    end
    #Selecionando os nós dos pesquisadores presentes na rede selecionada
    nos = Pesquisador.arel_table
    associacoes_pesquisadores_redes = AssociacaoPesquisadorRede.arel_table
    #**Selecionando apenas os ids dos pesquisadores pertencentes a rede
    @researchers_network = Pesquisador.select("id").where(AssociacaoPesquisadorRede.where(associacoes_pesquisadores_redes[:pesquisador_id].eq(nos[:id]).and associacoes_pesquisadores_redes[:rede_id].eq(@rede_id)).exists)
    if @researchers_network
      #Exibindo pesquisadores existentes no banco
      @pesquisadores = Pesquisador.select("id, nome").where("id not in (?)", @researchers_network).order(:nome)
      #Id do pesquisador selecionado
      @pesquisador_id = session[:pesquisador_id]
    else
      #Exibindo redes existentes no banco
      @pesquisadores = Pesquisador.order(:nome)
      #Id do pesquisador selecionado
      @pesquisador_id = session[:pesquisador_id]
    end
    #lista de instituições selecionáveis no filtro 
    @instituicoes = []
    @instituicoes_researchers_network = Pesquisador.select("distinct instituicao").where("id in (?)", @researchers_network)
    @instituicoes_selected_researcher = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @pesquisador_id, @pesquisador_id)
    @instituicoes = @instituicoes | @instituicoes_researchers_network
    @instituicoes = @instituicoes | @instituicoes_selected_researcher
          @nodes_target = Pesquisador.select("distinct nome as name, id, instituicao").where("(#{@institution} OR id = ?) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( link.target <> ? ) AND ( #{@amount} ) AND ( #{@year} ))", @target, @target, @researchers)
    @nodes_network = Pesquisador.select("distinct nome as name, `group`, id, instituicao").where("(#{@institution}) AND EXISTS (SELECT `associacao_pesquisador_rede`.* FROM `associacao_pesquisador_rede` WHERE (`associacao_pesquisador_rede`.`pesquisador_id` = `pesquisador`.`id` AND `associacao_pesquisador_rede`.`rede_id` = ?)) AND EXISTS ( SELECT link.id FROM link WHERE ( link.source = pesquisador.id ) AND ( #{@amount} ) AND ( #{@year} ))", @rede_id)
    @nodes_target = Pesquisador.select("distinct nome as name, `group`, id, instituicao").where("(#{@institution}) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( #{@amount} ) AND ( #{@year} ))", @pesquisador_id)
    @nodes_target_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @pesquisador_id) 
    @nodes_target = @nodes_target | @nodes_target_aux 
    #Encontrando os coautores em comum... 
    for id in @nodes_network.map(&:id)
      for id2 in @nodes_target.map(&:id)
        if id == id2
          @common.push id
        end
      end
    end
    @nodes_common = Pesquisador.select("distinct nome as name, `group`, id, instituicao").where("id in (?)", @common)  
    #Excluindo da lista de nós das redes de coautoria, os nós dos pesquisadores em comum...
    if @common.any?
       @nodes_network = @nodes_network.reject { |h| @common.include? h['id'] }
       @nodes_target = @nodes_target.reject { |h| @common.include? h['id'] }
    end 
    #Marcando pesquisadores
    Pesquisador.where('id in (?)', @nodes_target.map(&:id)).update_all('selecao = 1')
    Pesquisador.where('id in (?)', @nodes_network.map(&:id)).update_all('selecao = 1')
    #Determinando a cor dos nós através da coluna group...
    if @common.any?
      @nodes_common.each_with_index do |item, index|
        item.group = 3
      end
    end
    @nodes_network.each_with_index do |item, index|
      item.group = 1
    end
    @nodes_target.each_with_index do |item, index|
      item.group = 2
    end
    #Unindo todos os nós em uma única lista...
    @nodes = []
    @nodes = @nodes | @nodes_network
    @nodes = @nodes | @nodes_target
    @nodes = @nodes | @nodes_common   
    #Selecionando links...
    @links = Link.select("source, target, `value`, count_pub_target as count").where("source = ? AND (#{@amount}) AND (#{@year}) AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})
", @researchers)
    @links = Link.select("source, target, `value`, count_pub_target as count").where("((source in (?) AND target in (?)) OR (source in (?))) AND (#{@amount}) AND (#{@year}) AND EXISTS (SELECT * FROM pesquisador WHERE (link.target = pesquisador.id) AND #{@institution})", @researchers_network, @researchers_network, @pesquisador_id)
    #Selecionando os links das recomendações geradas
    @recommendedlink = []
    if session[:button] == "Affin"
      @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as value, value as classificacao").where("(pesquisador1_id in (?) and pesquisador2_id = ?) or (pesquisador1_id = ? and pesquisador2_id in (?)) AND metodo_id = 2", @researchers_network, @pesquisador_id, @pesquisador_id, @researchers_network).order('value DESC').limit(5)  
    elsif session[:button] == "Corals"
      @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as value, value as classificacao").where("(pesquisador1_id in (?) and pesquisador2_id = ?) or (pesquisador1_id = ? and pesquisador2_id in (?)) AND metodo_id = 3", @researchers_network, @pesquisador_id, @pesquisador_id, @researchers_network).order('value DESC').limit(5)  
    end
    #Controlando os forms e botões da view...
    if @rede_id and @rede_id != ""
      @sel_researcher = true 
    end
    if @rede_id and @pesquisador_id and @rede_id != "" and @pesquisador_id != ""
      @bot_submit = true
    end
    respond_to do |format|
       format.html  
       format.json { render :json => {:Nodes => @nodes, :Links => @links, :RecommendedLink => @recommendedlink}}
    end
  end

  def load_network
    session[:button] = nil
    session[:filter_network] = nil
    session[:amount_network] = nil
    session[:year_network] = nil
    session[:institution_network] = nil
    if session[:rede_id] != params[:select_network] and params[:select_network] == ""
      params[:select_researcher] = nil
    end
    #Buscando o id da rede selecionada...
    session[:rede_id] = params[:select_network]
    #Buscando o id do pesquisador selecionada...
    session[:pesquisador_id] = params[:select_researcher]
    redirect_to url_for(:action => :networks)
  end

  def filter_network
    #filtro?
    if params[:filter_network]
      session[:filter_network] = params[:filter_network]
    end
    #filtro quantidade
    if params[:amount_network] == ""
      session[:amount_network] = "1"
    else
      session[:amount_network] = params[:amount_network]
    end
    #filtro ano
    if params[:year_network] == ""
      session[:year_network] = "1"
    else
      session[:year_network] = params[:year_network]
    end
    #filtro instituicao
    if params[:institution_network] == ""
      session[:institution_network] = "1"
    else
      session[:institution_network] = params[:institution_network]
    end
    if params[:institution_network] == "" and params[:year_network] == "" and params[:amount_network] == ""
      session[:filter_network] = "false"
    end
    redirect_to url_for(:action => :networks)
  end

  def import_data_network
    #Está importando um único pesquisador e suas respectivas publicações ou uma rede com seus respectivos pesquisadores e publicações?
    if params[:import_define] == "researcher"
      verifica_pesquisador = 3
      verifica_publicacao = 3
      #Inserindo um novo pesquisador...
      if params[:network_researcher]
        verifica_pesquisador = PesquisadorAux.import(params[:network_researcher])
        system('python ' + (Rails.root).to_s + '/public/assets/InserePesquisador.py')
      end
      #Inserindo novas publicações...
      if params[:network_publications]
        verifica_publicacao = PublicacaoAux.import(params[:network_publications])
        system('python ' + (Rails.root).to_s + '/public/assets/InserePublicacoes.py')
      end
      #Excluindo pesquisadores e publicacoes inseridos anteriormente da tabela auxiliar...
      PesquisadorAux.destroy_all
      PublicacaoAux.destroy_all
      #Verificando o tipo dos arquivos inseridos...
      if verifica_pesquisador != 0 and verifica_publicacao != 0
        if verifica_pesquisador == 3 and verifica_publicacao == 3 
          redirect_to url_for(:action => :networks)
        else
          redirect_to url_for(:action => :networks), notice: "Publications and/or researcher imported."
        end
      elsif verifica_pesquisador != 0  and verifica_publicacao == 0
        redirect_to url_for(:action => :networks), :flash => { :error => "Unknown #{params[:network_publications].original_filename} type" }
      elsif verifica_pesquisador == 0 and verifica_publicacao != 0
        redirect_to url_for(:action => :networks), :flash => { :error => "Unknown #{params[:network_researcher].original_filename} type" }
      elsif verifica_pesquisador == 0 and verifica_publicacao == 0
        redirect_to url_for(:action => :networks), :flash => { :error => "Unknown #{params[:network_researcher].original_filename} and #{params[:network_publications].original_filename} types" }
      end
    elsif params[:import_define] == "network"
      #Nome da rede importada
      @network_nome = params[:network]
      verifica_pesquisadores = 3
      #Esta rede já está inserida no banco? Se sim a rede é atualizada. Se não a rede é inserida.
      if Rede.where(@network_nome).blank?
        #Inserindo a rede na tabela auxiliar...
        @insert_network_name = RedeAux.new(params[:network])
        @insert_network_name.save 
        #Inserindo pesquisadores em uma tabela auxiliar...
        if params[:network_researchers]
          verifica_pesquisadores = PesquisadorAux.import(params[:network_researchers])
          #Inserindo a rede...
          system('python ' + (Rails.root).to_s + '/public/assets/InsereRede.py')
        end
        #Excluindo pesquisadores e a rede inseridos anteriormente da tabela auxiliar...
        PesquisadorAux.destroy_all
        RedeAux.destroy_all
        #Desconsiderando o pesquisador selecionado...
        session[:pesquisador_id] = nil
        if verifica_pesquisadores == 0
          redirect_to url_for(:action => :networks), :flash => { :error => "The network was created without researchers because: 'Unknown #{params[:network_researchers].original_filename} type'" }
        else
          redirect_to url_for(:action => :networks), notice: "Network imported." 
        end
      else
        #Inserindo a rede na tabela auxiliar...
        @insert_network_name = RedeAux.new(params[:network])
        @insert_network_name.save 
        #Inserindo pesquisadores em uma tabela auxiliar...
        if params[:network_researchers]
          verifica_pesquisadores = PesquisadorAux.import(params[:network_researchers])
          #Inserindo a rede...
          system('python ' + (Rails.root).to_s + '/public/assets/InsereRede.py')
        end
        #Inserindo a rede...
        system('python ' + (Rails.root).to_s + '/public/assets/InsereRede.py')
        #Excluindo pesquisadores e a rede inseridos anteriormente da tabela auxiliar...
        PesquisadorAux.destroy_all
        RedeAux.destroy_all
        #Desconsiderando o pesquisador selecionado...
        session[:pesquisador_id] = nil
        if verifica_pesquisadores == 0
          redirect_to url_for(:action => :networks), :flash => { :error => "The network wasn't updated because: 'Unknown #{params[:network_researchers].original_filename} type'" }
        else
          redirect_to url_for(:action => :networks), notice: "Network updated." 
        end
      end
    end
    #Excluindo pesquisadores e publicacoes inseridos anteriormente da tabela auxiliar...
    PesquisadorAux.destroy_all
    PublicacaoAux.destroy_all
  end

  def generate_rec
    session[:button] = params[:commit]
    #Preparando o banco de dados para a geração das recomendações...
    system('python ' + (Rails.root).to_s + '/public/assets/Preparacao.py')
    if params[:commit] == "Affin"
      #Gerando as recomendações...
      system('php ' + (Rails.root).to_s + '/public/assets/GerarRecomendacoesAffin/main.php')
      #Inserindo as recomendacoes...
      system('python ' + (Rails.root).to_s + '/public/assets/InsereRecomendacoesAffin.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
    elsif params[:commit] == "Corals"
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
    redirect_to url_for(:action => :networks)
  end

  def update_network
    @selected_researcher_insert = session[:pesquisador_id]
    if params[:networks_update] 
      #Selecionando pesquisador para a atualização da sua rede...
      Pesquisador.where("id = ?", @selected_researcher_insert).update_all("sel_update = 1")
      #Gerando as novas colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/NewCollaborations.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
      #Desmarcando pesquisador...
      Pesquisador.where("id = ?", @selected_researcher_insert).update_all("sel_update = NULL")
      redirect_to url_for(:action => :networks), notice: "Network updated." 
    end
  end

end
