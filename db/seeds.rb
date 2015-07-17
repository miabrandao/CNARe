# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'json'

module AffinPopulate
  def self.affin
    ActiveSupport::JSON.decode(Rails.root.join("db", "affin.json"))
  end

  def self.populate

    affins = {}

    affin.each do |affin|	
      affin_obj = Affin.create!(:id => affin["id"],
                                :pesquisador1_id => affin["pesquisador1_id"],
                                :pesquisador2_id => affin["pesquisador2_id"],
                                :value => affin["value"])
    end   
	
  end
end

module AssociacaoPesquisadorInstituicaoPopulate
  def self.associacao_pesquisador_instituicao
    ActiveSupport::JSON.decode(Rails.root.join("db", "associacao_pesquisador_instituicao.json"))
  end

  def self.populate

    associacao_pesquisadores_instituicoes = {}

    associacao_pesquisador_instituicao.each do |associacao_pesquisador_instituicao|	
      associacao_pesquisador_instituicao_obj = AssociacaoPesquisadorInstituicao.create!(:id => associacao_pesquisador_instituicao["id"],
                                                                                        :inct_id => associacao_pesquisador_instituicao["inct_id"],
                                                                                        :endereco_id => associacao_pesquisador_instituicao["endereco_id"],
                                                                                        :instituicao_id => associacao_pesquisador_instituicao["instituicao_id"],
                                                                                        :pesquisador_id => 
associacao_pesquisador_instituicao["pesquisador_id"],
                                                                                        :tipo_associacao_pesquisador_instituicao_id => associacao_pesquisador_instituicao["tipo_associacao_pesquisador_instituicao_id"],
                                                                                        :descricao => associacao_pesquisador_instituicao["descricao"],
                                                                                        :data_inicio => associacao_pesquisador_instituicao["data_inicio"],
                                                                                        :data_fim => associacao_pesquisador_instituicao["data_fim"])
    end   
	
  end
end

module AutorPopulate
  def self.autor
    ActiveSupport::JSON.decode(Rails.root.join("db", "autor.json"))
  end

  def self.populate

    autores = {}

    autor.each do |autor|	
      autor_obj = Autor.create!(:id => autor["id"],
                                :pesquisador_id => autor["pesquisador_id"],
                                :modclass => autor["modclass"],
                                :selecao => autor["selecao"])
    end   
	
  end
end

module AutoriaAutorPublicacaoPopulate
  def self.autoria_autor_publicacao
    ActiveSupport::JSON.decode(Rails.root.join("db", "autoria_autor_publicacao.json"))
  end

  def self.populate

    autoria_autores_publicacoes = {}

    autoria_autor_publicacao.each do |autoria_autor_publicacao|	
      autoria_autor_publicacao_obj = AutoriaAutorPublicacao.create!(:id => autoria_autor_publicacao["id"],
                                                                    :autor_id => autoria_autor_publicacao["autor_id"],
                                                                    :publicacao_id => autoria_autor_publicacao["publicacao_id"],
                                                                    :ordem => autoria_autor_publicacao["ordem"])
    end   
	
  end
end

module CacheDadosTreinoPublicacaoPopulate
  def self.cache_dados_treino_publicacao
    ActiveSupport::JSON.decode(Rails.root.join("db", "cache_dados_treino_publicacao.json"))
  end

  def self.populate

    cache_dados_treino_publicacoes = {}

    cache_dados_treino_publicacao.each do |cache_dados_treino_publicacao|	
      cache_dados_treino_publicacao_obj = CacheDadosTreinoPublicacao.create!(:tema_id => cache_dados_treino_publicacao["tema_id"],
                                                                             :titulo => cache_dados_treino_publicacao["titulo"])
    end   
	
  end
end

module CidadePopulate
  def self.cidade
    ActiveSupport::JSON.decode(Rails.root.join("db", "cidade.json"))
  end

  def self.populate

    cidades = {}

    cidade.each do |cidade|	
      cidade_obj = Cidade.create!(:id => cidade["id"],
                                  :estado_id => cidade["estado_id"],
                                  :nome => cidade["nome"])
    end   
	
  end
end

module CidadeEstadoPaisPopulate
  def self.cidade_estado_pais
    ActiveSupport::JSON.decode(Rails.root.join("db", "cidade_estado_pais.json"))
  end

  def self.populate

    cidades_estados_paises = {}

    cidade_estado_pais.each do |cidade_estado_pais|	
      cidade_estado_pais_obj = CidadeEstadoPais.create!(:id => cidade_estado_pais["id"],
                                                        :pais_id => cidade_estado_pais["pais_id"],
                                                        :estado_id => cidade_estado_pais["estado_id"],
                                                        :cidade_id => cidade_estado_pais["cidade_id"])
    end   
	
  end
end

module CoralsPopulate
  def self.corals
    ActiveSupport::JSON.decode(Rails.root.join("db", "corals.json"))
  end

  def self.populate

    coralss = {}

    corals.each do |corals|	
      corals_obj = Corals.create!(:id => corals["id"],
                                :pesquisador1_id => corals["pesquisador1_id"],
                                :pesquisador2_id => corals["pesquisador2_id"],
                                :value => corals["value"])
    end   
	
  end
end

module EnderecoPopulate
  def self.endereco
    ActiveSupport::JSON.decode(Rails.root.join("db", "endereco.json"))
  end

  def self.populate

    enderecos = {}

    endereco.each do |endereco|	
      endereco_obj = Endereco.create!(:id => endereco["id"],
                                      :cidade_estado_pais_id => endereco["cidade_estado_pais_id"],
                                      :logradouro => endereco["logradouro"],
                                      :bairro => endereco["bairro"],
                                      :cep => endereco["cep"])
    end   
	
  end
end

module EstadoPopulate
  def self.estado
    ActiveSupport::JSON.decode(Rails.root.join("db", "estado.json"))
  end

  def self.populate

    estados = {}

    estado.each do |estado|	
      estado_obj = Estado.create!(:id => estado["id"],
                                  :pais_id => estado["pais_id"],
                                  :sigla => estado["sigla"],
                                  :nome => estado["nome"])
    end   
	
  end
end

module FormacaoAcademicaPopulate
  def self.formacao_academica
    ActiveSupport::JSON.decode(Rails.root.join("db", "formacao_academica.json"))
  end

  def self.populate

    formacoes_academicas = {}

    formacao_academica.each do |formacao_academica|	
      formacao_academica_obj = FormacaoAcademica.create!(:id => formacao_academica["id"],
                                                         :instituicao_formacao_academica_id => formacao_academica["instituicao_formacao_academica_id"],
                                                         :tipo_formacao_academica_id => formacao_academica["tipo_formacao_academica_id"],
                                                         :pesquisador_id => formacao_academica["pesquisador_id"],
                                                         :data_inicio => formacao_academica["data_inicio"],
                                                         :data_fim => formacao_academica["data_fim"],
                                                         :descricao => formacao_academica["descricao"])
    end   
	
  end
end

module InctPopulate
  def self.inct
    ActiveSupport::JSON.decode(Rails.root.join("db", "inct.json"))
  end

  def self.populate

    incts = {}

    inct.each do |inct|	
      inct_obj = Inct.create!(:id => inct["id"],
                              :area_conhecimento_id => inct["area_conhecimento_id"],
                              :inct_tema_id => inct["inct_tema_id"],
                              :nome => inct["nome"],
                              :link_oficial => inct["link_oficial"],
                              :link_2 => inct["link_2"])
    end   
	
  end
end

module InctTemaPopulate
  def self.inct_tema
    ActiveSupport::JSON.decode(Rails.root.join("db", "inct_tema.json"))
  end

  def self.populate

    inct_temas = {}

    inct_tema.each do |inct_tema|	
      inct_tema_obj = InctTema.create!(:id => inct_tema["id"],
                                       :nome => inct_tema["nome"])
    end   
	
  end
end

module InstituicaoPopulate
  def self.instituicao
    ActiveSupport::JSON.decode(Rails.root.join("db", "instituicao.json"))
  end

  def self.populate

    instituicoes = {}

    instituicao.each do |instituicao|	
      instituicao_obj = Instituicao.create!(:id => instituicao["id"],
                                            :cidade_estado_pais_id => instituicao["cidade_estado_pais_id"],
                                            :tipo_instituicao_id => instituicao["tipo_instituicao_id"],
                                            :nome => instituicao["nome"])
    end   
	
  end
end

module LinkPopulate
  def self.link
    ActiveSupport::JSON.decode(Rails.root.join("db", "link.json"))
  end

  def self.populate

    links = {}

    link.each do |link|	
      link_obj = Link.create!(:id => link["id"],
                              :source => link["source"],
                              :target => link["target"],
                              :value => link["value"],
                              :last_year_pub_target => link["last_year_pub_target"],
                              :count_pub_target => link["count_pub_target"])
    end   
	
  end
end

module NodePopulate
  def self.node
    ActiveSupport::JSON.decode(Rails.root.join("db", "node.json"))
  end

  def self.populate

    nodes = {}

    node.each do |node|	
      node_obj = Node.create!(:id => node["id"],
                              :name => node["name"])
    end   
	
  end
end

module PaisPopulate
  def self.pais
    ActiveSupport::JSON.decode(Rails.root.join("db", "pais.json"))
  end

  def self.populate

    paises = {}

    pais.each do |pais|	
      pais_obj = Pais.create!(:id => pais["id"],
      		              :nome => pais["nome"], 
                              :iso => pais["iso"], 
                              :iso3 => pais["iso3"],
                              :num_code => pais["num_code"])
    end   
	
  end
end

module PesquisadorPopulate
  def self.pesquisador
    ActiveSupport::JSON.decode(Rails.root.join("db", "pesquisador.json"))
  end

  def self.populate

    pesquisadores = {}

    pesquisador.each do |pesquisador|	
      pesquisador_obj = Pesquisador.create!(:id => pesquisador["id"],
      		                            :nome => pesquisador["nome"], 
                                            :nomeDsc => pesquisador["nomeDsc"], 
                                            :url_lattes => pesquisador["url_lattes"],
                                            :url_lattes_oficial => pesquisador["url_lattes_oficial"],
                                            :data_coleta_lattes => pesquisador["data_coleta_lattes"],
                                            :nivel_coleta => pesquisador["nivel_coleta"],
                                            :ult_data_atualizacao_lattes => pesquisador["ult_data_atualizacao_lattes"],
                                            :sexo => pesquisador["sexo"],
                                            :area => pesquisador["area"],
                                            :instituicao => pesquisador["instituicao"],
                                            :selecao => pesquisador["selecao"])
    end   
	
  end
end

module PublicacaoPopulate
  def self.publicacao
    ActiveSupport::JSON.decode(Rails.root.join("db", "publicacao.json"))
  end

  def self.populate

    publicacoes = {}

    publicacao.each do |publicacao|	
      publicacao_obj = Publicacao.create!(:id => publicacao["id"],
      		                          :autor_citacao_id => publicacao["autor_citacao_id"], 
                                          :publicacao_replica_id => publicacao["publicacao_replica_id"], 
                                          :edicao_id => publicacao["edicao_id"],
                                          :tipo_publicacao_id => publicacao["tipo_publicacao_id"],
                                          :titulo => publicacao["titulo"],
                                          :coautores => publicacao["coautores"],
                                          :doi => publicacao["doi"],
                                          :data_publicacao => publicacao["data_publicacao"],
                                          :data_insercao => publicacao["data_insercao"],
                                          :texto_citacao => publicacao["texto_citacao"],
                                          :pagina => publicacao["pagina"],
                                          :dsc_coautores => publicacao["dsc_coautores"],
                                          :dsc_dataPublicacao => publicacao["dsc_dataPublicacao"],
                                          :dsc_titulo => publicacao["dsc_titulo"],
                                          :tema_id => publicacao["tema_id"])
    end   
	
  end
end

module SearchSuggestionPopulate
  def self.search_suggestion
    ActiveSupport::JSON.decode(Rails.root.join("db", "search_suggestion.json"))
  end

  def self.populate

    search_suggestions = {}

    search_suggestion.each do |search_suggestion|	
      search_suggestion_obj = SearchSuggestion.create!(:id => search_suggestion["id"],
      		                                       :term => search_suggestion["term"], 
                                                       :popularity => search_suggestion["popularity"])
    end   
	
  end
end

module TemaPopulate
  def self.tema
    ActiveSupport::JSON.decode(Rails.root.join("db", "tema.json"))
  end

  def self.populate

    temas = {}

    tema.each do |tema|	
      tema_obj = Tema.create!(:id => tema["id"],
                              :nome => tema["nome"])
    end   
	
  end
end

module TipoFormacaoAcademicaPopulate
  def self.tipo_formacao_academica
    ActiveSupport::JSON.decode(Rails.root.join("db", "tipo_formacao_academica.json"))
  end

  def self.populate

    tipos_formacoes_academicas = {}

    tipo_formacao_academica.each do |tipo_formacao_academica|	
      tipo_formacao_academica_obj = TipoFormacaoAcademica.create!(:id => tipo_formacao_academica["id"],
                                                                  :nome => tipo_formacao_academica["nome"])
    end   
	
  end
end

AffinPopulate.populate
AssociacaoPesquisadorInstituicaoPopulate.populate
AutorPopulate.populate
AutoriaAutorPublicacaoPopulate.populate
CacheDadosTreinoPublicacaoPopulate.populate
CidadePopulate.populate
CidadeEstadoPaisPopulate.populate
CoralsPopulate.populate
EnderecoPopulate.populate
EstadoPopulate.populate
FormacaoAcademicaPopulate.populate
InctPopulate.populate
InctTemaPopulate.populate
InstituicaoPopulate.populate
LinkPopulate.populate
NodePopulate.populate
PaisPopulate.populate
PesquisadorPopulate.populate
PublicacaoPopulate.populate
SearchSuggestionPopulate.populate
TemaPopulate.populate
TipoFormacaoAcademicaPopulate.populate
