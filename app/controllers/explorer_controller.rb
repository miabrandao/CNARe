class ExplorerController < ApplicationController
  def explorer
    #Número da página
    @here = 7
    @researchers = session[:id]
    if @researchers 
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Affin.where("pesquisador1_id = ?", @researchers).order('value DESC')
      @corals = Corals.where("pesquisador1_id = ?", @researchers).order('value DESC')
    end
    @table_selection1 = session[:table_selection1]
    @nodes = []
    @nodes1 = @nodes2 = @nodes3 = []
    if (@table_selection1 == "Institution")
      @selection_options1 = Instituicao.select('distinct id, acronimo')
	.order('acronimo ASC')
      @selection1 = session[:selection1]
      if (@selection1 != "")
	@nome_instituicao1 = Instituicao.select("acronimo")
	  .where("id = ?", @selection1)
	  .map(&:acronimo)
	@nodes1 = Pesquisador.select("distinct pesquisador.nome as name, 1 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_instituicao ON pesquisador.id = associacao_pesquisador_instituicao.pesquisador_id")
	  .where("associacao_pesquisador_instituicao.instituicao_id = ? AND pesquisador.instituicao = ?", 
	      @selection1, @nome_instituicao1)
	@nodes = @nodes1
      end
    elsif (@table_selection1 == "Researcher")
      @selection_options1 = Pesquisador.select('distinct id, nome')
	.order('nome ASC')
      @selection1 = session[:selection1]
      if (@selection1 != "")
	@researcher1 = Pesquisador.select("nome")
	  .where("id = ?", @selection1)
	  .map(&:nome)
	@coautores1_id = Link.select("source as id")
	  .where("target = ?", @selection1)
	@cocoautores1_id = Link.select("source as id")
	  .where("target in (?)", @coautores1_id.map(&:id))
	@researchers1_ids = @cocoautores1_id | @coautores1_id
	@nodes1 = Pesquisador.select("distinct nome as name, 1 as 'group', id, instituicao")
	  .where("id in (?) OR id = ?", @researchers1_ids.map(&:id), @selection1);
	@links1 = Link.select("source, target, value")
	  .where("source < target AND source in (?) OR target in (?)", @nodes1.map(&:id), @nodes1.map(&:id))
	@nodes = @nodes1
      end
    elsif (@table_selection1 == "Network")
      @selection_options1 = Rede.select('distinct id, nome').order('nome ASC')
      @selection1 = session[:selection1]
      if (@selection1 != "")
	@nome_rede1 = Rede.select("nome")
	  .where("id = ?", @selection1)
	  .map(&:nome)
	@nodes1 = Pesquisador.select("distinct pesquisador.nome as name, 1 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_rede ON pesquisador.id = associacao_pesquisador_rede.pesquisador_id")
	  .where("associacao_pesquisador_rede.rede_id = ?", @selection1)
	@nodes = @nodes1
      end
    end

    @table_selection2 = session[:table_selection2]
    if (@table_selection2 == "Institution")
      @selection_options2 = Instituicao.select('distinct id, acronimo')
	.order('acronimo ASC')
      @selection2 = session[:selection2]
      if (@selection2 != "")
	@nome_instituicao2 = Instituicao.select("acronimo")
	  .where("id = ?", @selection2)
	  .map(&:acronimo)
	@nodes2 = Pesquisador.select("distinct pesquisador.nome as name, 2 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_instituicao ON pesquisador.id = associacao_pesquisador_instituicao.pesquisador_id")
	  .where("associacao_pesquisador_instituicao.instituicao_id = ? AND pesquisador.instituicao = ?", 
	      @selection2, @nome_instituicao2)
	@nodes = @nodes | @nodes2
      end
    elsif (@table_selection2 == "Researcher")
      @selection_options2 = Pesquisador.select('distinct id, nome')
	.order('nome ASC')
      @selection2 = session[:selection2]
      if (@selection2 != "")
	@researcher2 = Pesquisador.select("nome")
	  .where("id = ?", @selection2)
	  .map(&:nome)
	@coautores2_id = Link.select("source as id")
	  .where("target = ?", @selection2)
	@cocoautores2_id = Link.select("source as id")
	  .where("target in (?)", @coautores2_id.map(&:id))
	@researchers2_ids = @cocoautores2_id | @coautores2_id
	@nodes2 = Pesquisador.select("distinct nome as name, 2 as 'group', id, instituicao")
	  .where("id in (?) OR id = ?", @researchers2_ids.map(&:id), @selection2);
	@links2 = Link.select("source, target, value")
	  .where("source < target AND source in (?) OR target in (?)", @nodes2.map(&:id), @nodes2.map(&:id))
	@nodes = @nodes | @nodes2
      end
    elsif (@table_selection2 == "Network")
      @selection_options2 = Rede.select('distinct id, nome').order('nome ASC')
      @selection2 = session[:selection2]
      if (@selection2 != "")
	@nome_rede2 = Rede.select("nome")
	  .where("id = ?", @selection2)
	  .map(&:nome)
	@nodes2 = Pesquisador.select("distinct pesquisador.nome as name, 2 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_rede ON pesquisador.id = associacao_pesquisador_rede.pesquisador_id")
	  .where("associacao_pesquisador_rede.rede_id = ?", @selection2);
	@nodes = @nodes | @nodes2
      end
    end

    @table_selection3 = session[:table_selection3]
    if (@table_selection3 == "Institution")
      @selection_options3 = Instituicao.select('distinct id, acronimo')
	.order('acronimo ASC')
      @selection3 = session[:selection3]
      if (@selection3 != "")
	@nome_instituicao3 = Instituicao.select("acronimo")
	  .where("id = ?", @selection3)
	  .map(&:acronimo)
	@nodes3 = Pesquisador.select("distinct pesquisador.nome as name, 3 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_instituicao ON pesquisador.id = associacao_pesquisador_instituicao.pesquisador_id")
	  .where("associacao_pesquisador_instituicao.instituicao_id = ? AND pesquisador.instituicao = ?", @selection3, @nome_instituicao3)
	@nodes = @nodes | @nodes3
      end
    elsif (@table_selection3 == "Researcher")
      @selection_options3 = Pesquisador.select('distinct id, nome')
	.order('nome ASC')
      @selection3 = session[:selection3]
      if (@selection3 != "")
	@researcher3 = Pesquisador.select("nome")
	  .where("id = ?", @selection3)
	  .map(&:nome)
	@coautores3_id = Link.select("source as id")
	  .where("target = ?", @selection3)
	@cocoautores3_id = Link.select("source as id")
	  .where("target in (?)", @coautores3_id.map(&:id))
	@researchers3_ids = @cocoautores3_id | @coautores3_id
	@nodes3 = Pesquisador.select("distinct nome as name, 3 as 'group', id, instituicao")
	  .where("id in (?) OR id = ?", @researchers3_ids.map(&:id), @selection3);
	@nodes = @nodes | @nodes3
      end
    elsif (@table_selection3 == "Network")
      @selection_options3 = Rede.select('distinct id, nome').order('nome ASC')
      @selection3 = session[:selection3]
      if (@selection3 != "")
	@nome_rede3 = Rede.select("nome")
	  .where("id = ?", @selection3)
	  .map(&:nome)
	@nodes3 = Pesquisador.select("distinct pesquisador.nome as name, 3 as 'group', pesquisador.id, instituicao")
	  .joins("INNER JOIN associacao_pesquisador_rede ON pesquisador.id = associacao_pesquisador_rede.pesquisador_id")
	  .where("associacao_pesquisador_rede.rede_id = ?", @selection3);
	@nodes = @nodes | @nodes3
      end
    end
    if (!@nodes.nil?)
      @institutions = Pesquisador.select("count(id) as researchers, instituicao")
	.where("id in (?)", @nodes.map(&:id))#.map(&:instituicao)
	.group("instituicao")
      @links = Link.select("source, target, value")
	.where("source < target AND source in (?) AND target in (?)", @nodes.map(&:id), @nodes.map(&:id))
      #G1 e G2
      @g1_id = @nodes1.map(&:id)
      @g2_id = Pesquisador.select("id").where("id in (?) AND id NOT in (?)", @nodes2.map(&:id), @g1_id).map(&:id)
      @common_links_g1_g2 = Link.select("source, target, count_pub_target as value")
	.where("source in (?) AND target in (?)", @g1_id, @g2_id)
      @common_g1_id = (@common_links_g1_g2.map(&:source) | @common_links_g1_g2.map(&:target)) & @g1_id
      @common_g2_g1_id = (@common_links_g1_g2.map(&:source) | @common_links_g1_g2.map(&:target)) & @g2_id
      @common_nodes_g1_g2 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g1_id)
      @common_nodes_g2_g1 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g2_g1_id)
      #G1 e G3
      @g3_g1_id = Pesquisador.select("id").where("id in (?) AND id NOT in (?)", @nodes3.map(&:id), @g1_id | @g2_id).map(&:id)
      @common_links_g1_g3 = Link.select("source, target, count_pub_target as value")
	.where("source in (?) AND target in (?)", @g1_id, @g3_g1_id)
      @common_g1_g3_id = (@common_links_g1_g3.map(&:source) | @common_links_g1_g3.map(&:target)) & @g1_id
      @common_g3_g1_id = (@common_links_g1_g3.map(&:source) | @common_links_g1_g3.map(&:target)) & @g3_g1_id
      @common_nodes_g3_g1 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g3_g1_id)
      @common_nodes_g1_g3 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g1_g3_id)
      #G2 e G3
      @g3_g2_id = Pesquisador.select("id").where("id in (?) AND id NOT in (?)", @g3_g1_id, @g2_id).map(&:id)
      @common_links_g2_g3 = Link.select("source, target, count_pub_target as value")
	.where("source in (?) AND target in (?)", @g2_id, @g3_g2_id)
      @common_g2_g3_id = (@common_links_g2_g3.map(&:source) | @common_links_g2_g3.map(&:target)) & @g2_id
      @common_g3_g2_id = (@common_links_g2_g3.map(&:source) | @common_links_g2_g3.map(&:target)) & @g3_g2_id
      @common_nodes_g3_g2 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g3_g2_id)
      @common_nodes_g2_g3 = Pesquisador.select("distinct id, nome as name")
	.where("id in (?)", @common_g2_g3_id)
    end
    @s1 = []
    @s2 = []
    @s3 = []
    if (@table_selection1 == "Network")
      @s1 = @nome_rede1
    elsif (@table_selection1 == "Institution")
      @s1 = @nome_instituicao1
    elsif (@table_selection1 == "Researcher")
      @s1 = @researcher1
    end
    if (@table_selection2 == "Network")
      @s2 = @nome_rede2
    elsif (@table_selection2 == "Institution")
      @s2 = @nome_instituicao2
    elsif (@table_selection2 == "Researcher")
      @s2 = @researcher2
    end
    if (@table_selection3 == "Network")
      @s3 = @nome_rede3
    elsif (@table_selection3 == "Institution")
      @s3 = @nome_instituicao3
    elsif (@table_selection3 == "Researcher")
      @s3 = @researcher3
    end
    respond_to do |format|
      format.html
      format.json {
	render :json => {
	  :s1 => @s1,
	  :s2 => @s2,
	  :s3 => @s3,
	  :Nodes => @nodes,
	  :Links => @links,
	  :Institutions => @institutions,
	  :g1g2 => @common_nodes_g1_g2,
	  :g2g1 => @common_nodes_g2_g1,
	  :linksg1g2 => @common_links_g1_g2,
	  :g2g3 => @common_nodes_g2_g3,
	  :g3g2 => @common_nodes_g3_g2,
	  :linksg2g3 => @common_links_g2_g3,
	  :g1g3 => @common_nodes_g1_g3,
	  :g3g1 => @common_nodes_g3_g1,
	  :linksg1g3 => @common_links_g1_g3
	}
      }
    end
  end
  def load_institution
    if params[:select_institution1] == ""
      params[:select_institution2] = nil
    end
    #Buscando o id da instituicao selecionada...
    session[:table_selection1] = params[:select_table]
    session[:table_selection2] = params[:select_table2]
    session[:table_selection3] = params[:select_table3]
    session[:selection1] = params[:select_option1]
    session[:selection2] = params[:select_option2]
    session[:selection3] = params[:select_option3]
    redirect_to url_for(:action => :explorer)
  end
end
