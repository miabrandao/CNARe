class AlgorithmsController < ApplicationController

  def affin
    #Número da página
    @here = 2
    #Id do pesquisador consultado
    @researchers = session[:id]
    #Id do pesquisador recomendado selecionado
    @target = session[:affin_target].to_i
    #filtro?
    @filter = session[:filter_affin]
    #filtro quantidade
    if session[:amount_affin].nil?
      @amount = "1"
    else
      @amount = session[:amount_affin]
    end
    #filtro ano
    if session[:year_affin].nil?
      @year = "1"
    else
      @year = session[:year_affin]
    end
    #filtro instituicao
    if session[:institution_affin].nil?
      @institution = "1"
    else
      @institution = session[:institution_affin]
    end
    #filtro ano de formacao
    if session[:formation_period_affin].nil?
      @formation_period = "1)"
    else
      @formation_period = session[:formation_period_affin]
    end
    if @filter == "false"
      @amount = "1"
      @year = "1"
      @institution = "1"
      @formation_period = "1)"
    end
    #Inicializando lista de coautores em comum...
    @common = []
    if @researchers 
      #lista de instituições selecionáveis no filtro 
      @instituicoes = []
      @instituicoes_source = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @researchers, @researchers)
      @instituicoes_target = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @target, @target)
      @instituicoes = @instituicoes | @instituicoes_source
      @instituicoes = @instituicoes | @instituicoes_target
      #Buscando a lista de recomendações...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
      #Buscando os links...
      @links = Link.select("source, target, value, count_pub_target as count").where("source in (?, ?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador LEFT JOIN formacao_academica ON pesquisador.id = formacao_academica.pesquisador_id WHERE (link.target = pesquisador.id) AND #{@institution} HAVING MAX(#{@formation_period})", @researchers, @target) 
      #Nós da rede do pesquisador consultado
      @nodes_researcher = Pesquisador.select("distinct nome as name, pesquisador.id, instituicao").where("pesquisador.id in (?) AND ( #{@institution} OR pesquisador.id = ? ) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( #{@year} ) AND ( #{@amount} ) )", @links.map(&:target), @researchers, @researchers)
      #Nós da rede do pesquisador selecionado
      @nodes_target = Pesquisador.select("distinct nome as name, pesquisador.id, instituicao").where("pesquisador.id in (?) AND ( #{@institution} OR pesquisador.id = ? ) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( #{@year} ) AND ( #{@amount} ) )", @links.map(&:target), @target, @target)
      #Encontrando os coautores em comum... 
      for id in @nodes_researcher.map(&:id)
        for id2 in @nodes_target.map(&:id)
          if id == id2
            @common.push id
          end
        end
      end    
      @nodes_common = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id in (?)", @common)
      #Adicionando o nó do pesquisador consultado...
      @nodes_researcher_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @researchers)
      @nodes_researcher = @nodes_researcher | @nodes_researcher_aux
      #Adicionando o nó da recomendação selecionada...
      @nodes_target_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @target) 
      @nodes_target = @nodes_target | @nodes_target_aux   
      #Excluindo da lista de nós das redes de coautoria, os nós dos pesquisadores em comum...
      if @common.any?
        @nodes_researcher = @nodes_researcher.reject { |h| @common.include? h['id'] }
        @nodes_target = @nodes_target.reject { |h| @common.include? h['id'] }
      end  
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
      #Link da recomendação
      @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as `value`, value as classificacao").where("pesquisador1_id = ? and pesquisador2_id = ? AND metodo_id = 2", @researchers, @target)
      #Unindo todos os nós em uma única lista...
      @nodes = []
      @nodes = @nodes | @nodes_researcher
      @nodes = @nodes | @nodes_target
      @nodes = @nodes | @nodes_common
      @neighborhood = @nodes_common.size.to_f / (@nodes.size.to_f - 2.0)
      Recomenda.where("(pesquisador1_id = ? AND pesquisador2_id = ?) OR (pesquisador1_id = ? AND pesquisador2_id = ?)", @researchers, @target, @target, @researchers).update_all("neighborhood = #{@neighborhood}")
    end   
    respond_to do |format|
      format.html  
      format.json { render :json => {:Nodes => @nodes, :Links => @links, :RecommendedLink => @recommendedlink}}
    end
  end

  def create_affin
    #filtro?
    if params[:filter_affin]
      session[:filter_affin] = params[:filter_affin]
    end
    #filtro quantidade
    if params[:amount_affin] == ""
      session[:amount_affin] = "1"
    else
      session[:amount_affin] = params[:amount_affin]
    end
    #filtro ano
    if params[:year_affin] == ""
      session[:year_affin] = "1"
    else
      session[:year_affin] = params[:year_affin]
    end
    #filtro instituicao
    if params[:institution_affin] == ""
      session[:institution_affin] = "1"
    else
      session[:institution_affin] = params[:institution_affin]
    end
    #filtro ano formacao
    if params[:formation_period_affin] == ""
      session[:formation_period_affin] = "1)"
    else
      session[:formation_period_affin] = params[:formation_period_affin]
    end
    if params[:institution_affin] == "" and params[:year_affin] == "" and params[:amount_affin] == "" and params[:formation_period_affin] == ""
      session[:filter_affin] = "false"
    end
    #Recebendo id do pesquisador recomendado selecionado...
    if params[:affin_target] != nil
      #Cancelando filtros
      session[:filter_affin] = nil
      session[:amount_affin] = nil
      session[:year_affin] = nil
      session[:institution_affin] = nil
      session[:affin_target] = params[:affin_target]
    end
    redirect_to url_for(:action => :affin)
  end

  def corals
    #Número da página
    @here = 3
    #Id do pesquisador consultado
    @researchers = session[:id]
    #Id do pesquisador recomendado selecionado
    @target = session[:corals_target].to_i
    #filtro?
    @filter = session[:filter_corals]
    #filtro quantidade
    if session[:amount_corals].nil?
      @amount = "1"
    else
      @amount = session[:amount_corals]
    end
    #filtro ano
    if session[:year_corals].nil?
      @year = "1"
    else
      @year = session[:year_corals]
    end
    #filtro instituicao
    if session[:institution_corals].nil?
      @institution = "1"
    else
      @institution = session[:institution_corals]
    end
    #filtro ano de formacao
    if session[:formation_period_corals].nil?
      @formation_period = "1)"
    else
      @formation_period = session[:formation_period_corals]
    end
    if @filter == "false"
      @amount = "1"
      @year = "1"
      @institution = "1"
      @formation_period = "1)"
    end
    #Inicializando lista de coautores em comum...
    @common = []
    if @researchers
      #lista de instituições selecionáveis no filtro 
      @instituicoes = []
      @instituicoes_source = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @researchers, @researchers)
      @instituicoes_target = Pesquisador.select("distinct instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?))", @target, @target)
      @instituicoes = @instituicoes | @instituicoes_source
      @instituicoes = @instituicoes | @instituicoes_target
      #Buscando a lista de recomendações...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
      #Buscando os links...
      @links = Link.select("source, target, value, count_pub_target as count").where("source in (?, ?) AND #{@amount} AND #{@year} AND EXISTS (SELECT * FROM pesquisador LEFT JOIN formacao_academica ON pesquisador.id = formacao_academica.pesquisador_id WHERE (link.target = pesquisador.id) AND #{@institution} HAVING MAX(#{@formation_period})", @researchers, @target) 
      #Nós da rede do pesquisador consultado
      @nodes_researcher = Pesquisador.select("distinct nome as name, pesquisador.id, instituicao").where("pesquisador.id in (?) AND ( #{@institution} OR pesquisador.id = ? ) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( #{@year} ) AND ( #{@amount} ) )", @links.map(&:target), @researchers, @researchers)
      #Nós da rede do pesquisador selecionado
      @nodes_target = Pesquisador.select("distinct nome as name, pesquisador.id, instituicao").where("pesquisador.id in (?) AND ( #{@institution} OR pesquisador.id = ? ) AND EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? ) AND ( #{@year} ) AND ( #{@amount} ) )", @links.map(&:target), @target, @target)
      #Encontrando os coautores em comum... 
      for id in @nodes_researcher.map(&:id)
        for id2 in @nodes_target.map(&:id)
          if id == id2
            @common.push id
          end
        end
      end
      @nodes_common = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id in (?)", @common)
      #Adicionando o nó do pesquisador consultado...
      @nodes_researcher_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @researchers)
      @nodes_researcher = @nodes_researcher | @nodes_researcher_aux
      #Adicionando o nó da recomendação selecionada...
      @nodes_target_aux = Pesquisador.select("distinct nome as name, id, `group`, instituicao").where("id = ?", @target) 
      @nodes_target = @nodes_target | @nodes_target_aux   
      #Excluindo da lista de nós das redes de coautoria, os nós dos pesquisadores em comum...
      if @common.any?
        @nodes_researcher = @nodes_researcher.reject { |h| @common.include? h['id'] }
        @nodes_target = @nodes_target.reject { |h| @common.include? h['id'] }
      end  
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
      #Link da recomendação
      @recommendedlink = Recomenda.select("pesquisador1_id as source, pesquisador2_id as target, 1 as `value`, value as classificacao").where("pesquisador1_id = ? and pesquisador2_id = ? AND metodo_id = 3", @researchers, @target)
      #Unindo todos os nós em uma única lista...
      @nodes = []
      @nodes = @nodes | @nodes_researcher
      @nodes = @nodes | @nodes_target
      @nodes = @nodes | @nodes_common
      @neighborhood = @nodes_common.size.to_f / (@nodes.size.to_f - 2.0)
      Recomenda.where("(pesquisador1_id = ? AND pesquisador2_id = ?) OR (pesquisador1_id = ? AND pesquisador2_id = ?)", @researchers, @target, @target, @researchers).update_all("neighborhood = #{@neighborhood}")
    end
    respond_to do |format|
      format.html  
      format.json { render :json => {:Nodes => @nodes, :Links => @links, :RecommendedLink => @recommendedlink}}
    end
  end

  def create_corals
    #filtro?
    if params[:filter_corals]
      session[:filter_corals] = params[:filter_corals]
    end
    #filtro quantidade
    if params[:amount_corals] == ""
      session[:amount_corals] = "1"
    else
      session[:amount_corals] = params[:amount_corals]
    end
    #filtro ano
    if params[:year_corals] == ""
      session[:year_corals] = "1"
    else
      session[:year_corals] = params[:year_corals]
    end
    #filtro instituicao
    if params[:institution_corals] == ""
      session[:institution_corals] = "1"
    else
      session[:institution_corals] = params[:institution_corals]
    end
    #filtro ano formacao
    if params[:formation_period_corals] == ""
      session[:formation_period_corals] = "1)"
    else
      session[:formation_period_corals] = params[:formation_period_corals]
    end
    if params[:institution_corals] == "" and params[:year_corals] == "" and params[:amount_corals] == "" and params[:formation_period_corals] == ""
      session[:filter_corals] = "false"
    end
    #Recebendo id do pesquisador recomendado selecionado...
    if params[:corals_target] != nil
      #Descartando os filtros anteriores
      session[:filter_corals] = nil
      session[:amount_corals] = nil
      session[:year_corals] = nil
      session[:institution_corals] = nil
      session[:corals_target] = params[:corals_target]
    end
    redirect_to url_for(:action => :corals)
  end

  def update_network
    @researchers = session[:id]
    @affins = session[:affin_target]
    @corals = session[:corals_target]
    if params[:affin_update] 
      #Selecionando pesquisador para a atualização da sua rede...
      Pesquisador.where("id = ? OR id = ?", @affins, @researchers).update_all("sel_update = 1")
      #Gerando as novas colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/NewCollaborations.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
      #Desmarcando pesquisador...
      Pesquisador.where("id = ? OR id = ?", @affins, @researchers).update_all("sel_update = NULL")
      redirect_to url_for(:action => :affin), notice: "Networks updated." 
    elsif params[:corals_update] 
      #Selecionando pesquisador para a atualização da sua rede...
      Pesquisador.where("id = ? OR id = ?", @corals, @researchers).update_all("sel_update = 1")
      #Gerando as novas colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/NewCollaborations.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
      #Desmarcando pesquisador...
      Pesquisador.where("id = ? OR id = ?", @corals, @researchers).update_all("sel_update = NULL")
      redirect_to url_for(:action => :corals), notice: "Networks updated." 
    end
  end

end
