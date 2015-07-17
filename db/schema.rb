# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150415164126) do

  create_table "affin", :force => true do |t|
    t.integer "pesquisador1_id"
    t.integer "pesquisador2_id"
    t.float   "value"
  end

  create_table "area_conhecimento", :force => true do |t|
    t.string "nome", :null => false
  end

  add_index "area_conhecimento", ["id"], :name => "id", :unique => true

  create_table "associacao_pesquisador_area", :force => true do |t|
    t.integer "pesquisador_id"
    t.integer "area_id"
  end

  create_table "associacao_pesquisador_instituicao", :force => true do |t|
    t.integer "inct_id"
    t.integer "endereco_id"
    t.integer "instituicao_id"
    t.integer "pesquisador_id"
    t.integer "tipo_associacao_pesquisador_instituicao_id"
    t.string  "descricao"
    t.date    "data_inicio"
    t.date    "data_fim"
  end

  add_index "associacao_pesquisador_instituicao", ["endereco_id"], :name => "index_associacao_pesquisador_instituicao_on_endereco_id"
  add_index "associacao_pesquisador_instituicao", ["inct_id"], :name => "index_associacao_pesquisador_instituicao_on_inct_id"
  add_index "associacao_pesquisador_instituicao", ["instituicao_id"], :name => "index_associacao_pesquisador_instituicao_on_instituicao_id"
  add_index "associacao_pesquisador_instituicao", ["pesquisador_id"], :name => "index_associacao_pesquisador_instituicao_on_pesquisador_id"
  add_index "associacao_pesquisador_instituicao", ["tipo_associacao_pesquisador_instituicao_id"], :name => "my_index"

  create_table "associacao_pesquisador_rede", :force => true do |t|
    t.integer "pesquisador_id"
    t.integer "rede_id"
  end

  add_index "associacao_pesquisador_rede", ["pesquisador_id"], :name => "index_associacao_pesquisador_rede_on_pesquisador_id"
  add_index "associacao_pesquisador_rede", ["rede_id"], :name => "index_associacao_pesquisador_rede_on_rede_id"

  create_table "autor", :force => true do |t|
    t.integer "pesquisador_id"
    t.integer "modclass"
    t.integer "selecao"
  end

  add_index "autor", ["pesquisador_id"], :name => "index_autor_on_pesquisador_id", :unique => true

  create_table "autor_publicacao_instituicao", :id => false, :force => true do |t|
    t.integer "autor_id"
    t.integer "inct_id"
    t.integer "instituicao_id"
    t.integer "publicacao_id"
  end

  create_table "autoria_autor_publicacao", :force => true do |t|
    t.integer "autor_id"
    t.integer "publicacao_id"
    t.integer "ordem"
  end

  add_index "autoria_autor_publicacao", ["autor_id"], :name => "index_autoria_autor_publicacao_on_autor_id"
  add_index "autoria_autor_publicacao", ["publicacao_id"], :name => "index_autoria_autor_publicacao_on_publicacao_id"

  create_table "cidade", :force => true do |t|
    t.integer "estado_id"
    t.string  "nome"
  end

  add_index "cidade", ["estado_id"], :name => "index_cidade_on_estado_id"

  create_table "cidade_estado_pais", :force => true do |t|
    t.integer "pais_id"
    t.integer "estado_id"
    t.integer "cidade_id"
  end

  add_index "cidade_estado_pais", ["cidade_id"], :name => "index_cidade_estado_pais_on_cidade_id"
  add_index "cidade_estado_pais", ["estado_id"], :name => "index_cidade_estado_pais_on_estado_id"
  add_index "cidade_estado_pais", ["pais_id"], :name => "index_cidade_estado_pais_on_pais_id"

  create_table "corals", :force => true do |t|
    t.integer "pesquisador1_id"
    t.integer "pesquisador2_id"
    t.float   "value"
  end

  create_table "endereco", :force => true do |t|
    t.integer "cidade_estado_pais_id"
    t.text    "logradouro"
    t.string  "bairro"
    t.string  "cep"
  end

  add_index "endereco", ["cidade_estado_pais_id"], :name => "index_endereco_on_cidade_estado_pais_id"

  create_table "estado", :force => true do |t|
    t.integer "pais_id"
    t.string  "sigla"
    t.string  "nome"
  end

  add_index "estado", ["pais_id"], :name => "index_estado_on_pais_id"

  create_table "formacao_academica", :force => true do |t|
    t.integer "instituicao_formacao_academica_id"
    t.integer "tipo_formacao_academica_id"
    t.integer "pesquisador_id"
    t.date    "data_inicio"
    t.date    "data_fim"
    t.text    "descricao"
  end

  add_index "formacao_academica", ["instituicao_formacao_academica_id"], :name => "index_formacao_academica_on_instituicao_formacao_academica_id"
  add_index "formacao_academica", ["pesquisador_id"], :name => "index_formacao_academica_on_pesquisador_id"
  add_index "formacao_academica", ["tipo_formacao_academica_id"], :name => "index_formacao_academica_on_tipo_formacao_academica_id"

  create_table "inct", :force => true do |t|
    t.integer "area_conhecimento_id"
    t.integer "inct_tema_id"
    t.string  "nome"
    t.text    "link_oficial"
    t.text    "link_2"
  end

  add_index "inct", ["area_conhecimento_id"], :name => "index_inct_on_area_conhecimento_id"
  add_index "inct", ["inct_tema_id"], :name => "index_inct_on_inct_tema_id"
  add_index "inct", ["nome"], :name => "index_inct_on_nome", :unique => true

  create_table "inct_tema", :force => true do |t|
    t.string "nome"
  end

  create_table "instituicao", :force => true do |t|
    t.integer "cidade_estado_pais_id"
    t.integer "tipo_instituicao_id"
    t.string  "nome"
    t.string  "acronimo"
  end

  add_index "instituicao", ["cidade_estado_pais_id"], :name => "index_instituicao_on_cidade_estado_pais_id"
  add_index "instituicao", ["tipo_instituicao_id"], :name => "index_instituicao_on_tipo_instituicao_id"

  create_table "link", :force => true do |t|
    t.integer "source"
    t.integer "target"
    t.integer "value"
    t.integer "last_year_pub_target"
    t.integer "count_pub_target"
  end

  create_table "metodo", :force => true do |t|
    t.string "nome"
  end

  create_table "node", :force => true do |t|
    t.string  "name"
    t.integer "group"
  end

  create_table "pais", :force => true do |t|
    t.string  "nome"
    t.string  "iso"
    t.string  "iso3"
    t.integer "num_code"
  end

  create_table "pesquisador", :force => true do |t|
    t.string  "nome"
    t.string  "nomeDsc"
    t.string  "url_lattes"
    t.string  "url_lattes_oficial"
    t.date    "data_coleta_lattes"
    t.integer "nivel_coleta"
    t.date    "ult_data_atualizacao_lattes"
    t.string  "sexo"
    t.text    "area"
    t.string  "instituicao"
    t.integer "selecao"
    t.integer "sel_update"
    t.integer "group"
  end

  create_table "pesquisador_aux", :force => true do |t|
    t.string "name"
    t.text   "research_area"
    t.string "institution"
    t.string "acronym"
  end

  create_table "publicacao", :force => true do |t|
    t.integer "autor_citacao_id"
    t.integer "publicacao_replica_id"
    t.integer "edicao_id"
    t.integer "tipo_publicacao_id"
    t.text    "titulo"
    t.text    "coautores"
    t.text    "doi"
    t.date    "data_publicacao"
    t.date    "data_insercao"
    t.text    "texto_citacao"
    t.text    "pagina"
    t.text    "dsc_coautores"
    t.text    "dsc_dataPublicacao"
    t.text    "dsc_titulo"
    t.integer "tema_id"
  end

  add_index "publicacao", ["autor_citacao_id"], :name => "index_publicacao_on_autor_citacao_id"
  add_index "publicacao", ["edicao_id"], :name => "index_publicacao_on_edicao_id"
  add_index "publicacao", ["publicacao_replica_id"], :name => "index_publicacao_on_publicacao_replica_id"
  add_index "publicacao", ["tipo_publicacao_id"], :name => "index_publicacao_on_tipo_publicacao_id"

  create_table "publicacao_aux", :force => true do |t|
    t.text "title"
    t.date "date_of_publication"
    t.text "area"
    t.text "authors"
    t.text "venue"
  end

  create_table "recomenda", :force => true do |t|
    t.integer "pesquisador1_id"
    t.integer "pesquisador2_id"
    t.integer "metodo_id"
    t.float   "value"
    t.float   "neighborhood"
  end

  create_table "rede", :force => true do |t|
    t.string "nome"
  end

  create_table "rede_aux", :force => true do |t|
    t.string "nome"
  end

  create_table "search_suggestion", :force => true do |t|
    t.string  "term"
    t.integer "popularity"
  end

  create_table "tema", :force => true do |t|
    t.string "nome"
  end

  create_table "tipo_formacao_academica", :force => true do |t|
    t.string "nome"
  end

end
