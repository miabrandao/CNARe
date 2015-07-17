# encoding: UTF-8
class HomeController < ApplicationController

  def index
    #Número da página
    @here = 1
    #Buscando as recomendações de colaboração...
    @researchers = session[:id]
    #Instituições que serão comparadas
    @compare = session[:compare]
    #Nome do pesquisador consultado
    @nome = ""
    if @researchers
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
      #Nome do pesquisador consultado
      @nome = Pesquisador.select('nome').where('id = ?', @researchers).map(&:nome)
    end
    #Conjunto de ids dos pesquisadores recomendados   
    @rec_ids = []
    if @affins
      @rec_ids = @rec_ids | @affins.map(&:pesquisador2_id)
    end
    if @corals
      @rec_ids = @rec_ids | @corals.map(&:pesquisador2_id)
    end
    #Conjunto de associacoes entre pesquisadores e areas
    @associacoes = []
    for x in 0 ... @rec_ids.length 
      @associacoes[x] = AssociacaoPesquisadorArea.where("pesquisador_id = ?", @rec_ids[x])
    end    
    #Montando o grafo...
    @links = Link.select("source, target, `value`, count_pub_target as count").where("source = ?", @researchers)
    @nodes_aux = Pesquisador.select("distinct nome as name, id, instituicao").where("id = ?", @researchers)
    @nodes = Pesquisador.select("distinct nome as name, id, instituicao").where("EXISTS ( SELECT link.id FROM link WHERE ( link.target = pesquisador.id ) AND ( link.source = ? OR link.target = ?)) AND id <> ?", @researchers, @researchers, @researchers)
    @nodes = @nodes | @nodes_aux
    #Numero de areas que cada pesquisador possui no banco
    @num_associacoes = Array.new(@rec_ids.size) { Array.new(2) }
    #Instituicoes das recomendacoes...
    @instituicoes = []
    for x in 0 ... @rec_ids.length 
      @num_associacoes[x][0] = @rec_ids[x]
      @num_associacoes[x][1] = AssociacaoPesquisadorArea.count(:conditions => ['pesquisador_id = ?', @rec_ids[x]])
      @instituicoes[x] = Instituicao.select("distinct instituicao.*, associacao_pesquisador_instituicao.pesquisador_id").joins('INNER JOIN associacao_pesquisador_instituicao ON associacao_pesquisador_instituicao.instituicao_id = instituicao.id').where('associacao_pesquisador_instituicao.pesquisador_id = ?', @rec_ids[x]).first
    end
    #Áreas dos pesquisadores recomendados
    @rec_areas = AreaConhecimento.joins('INNER JOIN associacao_pesquisador_area ON associacao_pesquisador_area.area_id = area_conhecimento.id').where('associacao_pesquisador_area.pesquisador_id in (?)', @rec_ids)
    respond_to do |format|
      format.html  
      format.json { render :json => {:Nodes => @nodes, :Links => @links}}
    end
  end

 
  def create
    #Apagando sessões do pesquisador anterior
    session[:compare] = nil
    session[:affin_target] = nil
    session[:filter_affin] = nil
    session[:amount_affin] = nil
    session[:year_affin] = nil
    session[:institution_affin] = nil
    session[:formation_period_affin] = nil
    session[:corals_target] = nil
    session[:filter_corals] = nil
    session[:amount_corals] = nil
    session[:year_corals] = nil
    session[:institution_corals] = nil
    session[:formation_period_corals] = nil
    session[:filter_insert] = nil
    session[:amount_insert] = nil
    session[:year_insert] = nil
    session[:institution_insert] = nil
    session[:pesquisador_id_insert] = nil
    session[:button_insert] = nil
    session[:filter_network] = nil
    session[:amount_network] = nil
    session[:year_network] = nil
    session[:institution_network] = nil
    session[:rede_id] = nil
    session[:pesquisador_id] = nil
    session[:button] = nil
    #Buscando o id do pesquisador a partir do nome...
    session[:id] = Pesquisador.search(params[:search]).map(&:id)
    respond_to do |format|
      format.html {
        redirect_to "/", status: :moved_permanently
	}
    end
  end  

  def compare
    session[:compare] = params[:select_algorithms]
    redirect_to "/", status: :moved_permanently
  end

  def update_network
    @researchers = session[:id]
    if params[:index_update] 
      #Selecionando pesquisador para a atualização da sua rede...
      Pesquisador.where("id = ?", @researchers).update_all("sel_update = 1")
      #Gerando as novas colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/NewCollaborations.py')
      #calculando a intensidade das colaborações...
      system('python ' + (Rails.root).to_s + '/public/assets/CalculaIntensidade.py')
      #calculando o ano da ultima publicação
      system('python ' + (Rails.root).to_s + '/public/assets/DefineAnoUltimaPublicacao.py')
      #Desmarcando pesquisador...
      Pesquisador.where("id = ?", @researchers).update_all("sel_update = NULL")
      redirect_to url_for(:action => :index), notice: "Network updated."     
    end
  end
  
  def edit
    @researchers = session[:id]
    if @researchers 
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
    end
    @pesquisador_id = session[:edit_pesquisador_id]
    if params[:researcher_id]
      session[:edit_pesquisador_id] = params[:researcher_id]
    end
    @pesquisador = Pesquisador.where('id = ?', session[:edit_pesquisador_id])
    @instituicao_pesquisador = Instituicao.joins('INNER JOIN associacao_pesquisador_instituicao ON associacao_pesquisador_instituicao.instituicao_id = instituicao.id').where('associacao_pesquisador_instituicao.pesquisador_id = ?', session[:edit_pesquisador_id])
    @areas_pesquisador = AreaConhecimento.joins('INNER JOIN associacao_pesquisador_area ON associacao_pesquisador_area.area_id = area_conhecimento.id').where('associacao_pesquisador_area.pesquisador_id = ?', session[:edit_pesquisador_id])
    @num_formacoes = FormacaoAcademica.count(:conditions => "pesquisador_id = #{session[:edit_pesquisador_id]}")
    @formacoes = FormacaoAcademica.select("tipo_formacao_academica.nome, instituicao_formacao_academica_id, data_inicio, data_fim").joins('INNER JOIN tipo_formacao_academica ON tipo_formacao_academica.id = tipo_formacao_academica_id').where('pesquisador_id = ?', session[:edit_pesquisador_id]).order('YEAR(data_inicio) asc')
  end

  def edit_informations
    @pesquisador_id = session[:edit_pesquisador_id]
    #Editando a instituicao
    if params[:nome_instituicao] and params[:nome_instituicao] != ""
      num_instituicao = Instituicao.count(:conditions => ['nome = ? or acronimo = ?', params[:nome_instituicao], params[:nome_instituicao]])
      if num_instituicao == 0
        Instituicao.create([{ :nome => params[:nome_instituicao], :acronimo => params[:nome_instituicao] }])
      end
      @instituicao_id = Instituicao.select('id').where('nome = ? or acronimo = ?', params[:nome_instituicao], params[:nome_instituicao]).map(&:id).first
      AssociacaoPesquisadorInstituicao.where('pesquisador_id = ?', @pesquisador_id).update_all( :instituicao_id => @instituicao_id )
    end

    #Inserindo area
    if params[:nome_area] and params[:nome_area] != ""
      num_area = AreaConhecimento.count(:conditions => ['nome = ?', params[:nome_area]])
      if num_area == 0
        AreaConhecimento.create([{ :nome => params[:nome_area] }])
      end
      @area_id = AreaConhecimento.select('id').where('nome = ?', params[:nome_area]).map(&:id).first
      AssociacaoPesquisadorArea.create([{ :area_id => @area_id, :pesquisador_id => @pesquisador_id }])
    end

    #Inserindo formação academica
    if params[:start_year] and params[:completion_year] and params[:nome_instituicao_formacao] and params[:academic_degree] and params[:start_year] != "" and params[:completion_year] != "" and params[:nome_instituicao_formacao] != "" and params[:academic_degree] != ""
      #Encontrando o Id da instituição enviada...
      num_instituicao = Instituicao.count(:conditions => ['nome = ? or acronimo = ?', params[:nome_instituicao_formacao], params[:nome_instituicao_formacao]])
      if num_instituicao == 0
        Instituicao.create([{ :nome => params[:nome_instituicao_formacao], :acronimo => params[:nome_instituicao_formacao] }])
      end
      @instituicao_id = Instituicao.select('id').where('nome = ? or acronimo = ?', params[:nome_instituicao_formacao], params[:nome_instituicao_formacao]).map(&:id).first
      #Encontrando o Id do tipo de formação acadêmica...
      @tipo_formacao_id = TipoFormacaoAcademica.select('id').where('nome = ?', params[:academic_degree]).map(&:id).first

      sql = "INSERT INTO formacao_academica (instituicao_formacao_academica_id, tipo_formacao_academica_id, pesquisador_id, data_inicio, data_fim) VALUES (#{@instituicao_id}, #{@tipo_formacao_id}, #{@pesquisador_id}, '#{params[:start_year].to_i}-#{params[:start_month].to_i}-#{params[:start_day].to_i}', '#{params[:completion_year].to_i}-#{params[:completion_month].to_i}-#{params[:completion_day].to_i}')"
      ActiveRecord::Base.connection.execute(sql) 
    end
    redirect_to url_for(:action => :edit)
  end

  def remove_area
    AssociacaoPesquisadorArea.where(pesquisador_id: params[:p_id]).where(area_id: params[:a_id]).delete_all
    redirect_to url_for(:action => :edit)
  end
  
end
